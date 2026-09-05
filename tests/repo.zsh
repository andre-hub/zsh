#!/usr/bin/env zsh
emulate -LR zsh
setopt err_exit no_unset pipe_fail
root=${0:A:h:h}
if [[ ${REPO_TEST_ISOLATED:-} != 1 ]]; then
  exec env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin HOME=/nonexistent LANG=C LC_ALL=C \
    REPO_TEST_ISOLATED=1 "${commands[zsh]}" -d -f "$0"
fi
work=$(mktemp -d "$root/tests/.repo.XXXXXXXX")
trap '/bin/rm -rf -- "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
(
  mkdir -p "$work/bin" "$work/home" "$work/checkout"
  export HOME="$work/home" ZDOTDIR="$work/home" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
  export TRACE="$work/trace" WEB_TRACE="$work/web" GH_TRACE="$work/gh" TEA_TRACE="$work/tea"
  unset GIT_DIR GIT_WORK_TREE GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS
  command git init -q "$work/checkout"
  cd "$work/checkout"
  command git symbolic-ref HEAD refs/heads/feature/topic
  command git remote add origin https://github.com/example/project.git
  realgit=${commands[git]}
  print -rl -- '#!/bin/sh' 'for arg do if [ "$arg" = push ]; then printf "%s\n" "$@" > "$TRACE"; exit "${PUSH_FAILURE:-0}"; fi; done' \
    "exec ${(q)realgit} \"\$@\"" > "$work/bin/git"
  print -rl -- '#!/bin/sh' 'printf "%s\n" "$@" > "$WEB_TRACE"' 'exit "${BROWSER_FAILURE:-0}"' > "$work/bin/xdg-open"
  print -rl -- '#!/bin/sh' 'printf "%s\n" "$@" > "$GH_TRACE"' 'case "$*" in *--json*) printf "%s" "${PR_NUMBER:-}";; esac' > "$work/bin/gh"
  export TEA_LOGINS='[{"name":"fixture","url":"https://forge.invalid/git"}]' TEA_PULLS='[]'
  print -rl -- '#!/bin/sh' 'case "$*" in' \
    '"login list --output json") printf "%s" "$TEA_LOGINS"; exit "${TEA_FAILURE:-0}";;' \
    'esac' 'printf "%s\n" "$@" > "$TEA_TRACE"' \
    'case "$*" in *--output*) printf "%s" "$TEA_PULLS";; esac' > "$work/bin/tea"
  chmod +x "$work/bin/"*
  path=("$work/bin" /usr/bin /bin)
  source "$root/zshlib/repo.zsh"
  integer passed=0 failed=0
  check() {
    local label=$1; shift
    if ( "$@" ) > "$work/result" 2>&1; then
      print "ok - $label"; (( ++passed ))
    else print "not ok - $label"; (( ++failed )); fi
  }
  reset_traces() { : > "$TRACE"; : > "$WEB_TRACE"; : > "$GH_TRACE"; : > "$TEA_TRACE"; }
  github_open() { repo-open; [[ $(<"$WEB_TRACE") == https://github.com/example/project ]]; }
  push_branch() {
    repo-pr --base develop
    [[ $(<"$WEB_TRACE") == 'https://github.com/example/project/compare/develop...feature%2Ftopic?expand=1' ]] &&
      [[ $(<"$TRACE") == *$'push\n--recurse-submodules=no\n--\norigin\nrefs/heads/feature/topic:refs/heads/feature/topic' ]] &&
      [[ $(<"$TRACE") != *--force* ]]
  }
  failed_push() { export PUSH_FAILURE=1; reset_traces; ! repo-pr && [[ ! -s $WEB_TRACE ]]; }
  failed_browser() { export BROWSER_FAILURE=1; repo-pr > "$work/partial" 2>&1 && return 1; [[ $(<"$work/partial") == *'push succeeded, but browser'* && -s $TRACE ]]; }
  existing_pr() { export PR_NUMBER=42; repo-pr; [[ $(<"$WEB_TRACE") == https://github.com/example/project/pull/42 ]]; }
  blocked_push() {
    command git config remote.origin.pushurl /dev/null
    reset_traces
    ! repo-pr && [[ ! -s $TRACE && ! -s $WEB_TRACE ]]
  }
  mismatched_push() {
    command git config remote.origin.pushurl https://github.com/example/different.git
    reset_traces
    ! repo-pr && [[ ! -s $TRACE && ! -s $WEB_TRACE ]]
  }
  multiple_push() {
    command git config remote.origin.pushurl https://github.com/example/project.git
    command git config --add remote.origin.pushurl https://github.com/example/project.git
    reset_traces
    ! repo-pr && [[ ! -s $TRACE && ! -s $WEB_TRACE ]]
  }
  rewritten_push() {
    command git config --unset-all remote.origin.pushurl || :
    command git config url.https://github.com/example/different.git.pushInsteadOf https://github.com/example/project.git
    reset_traces
    ! repo-pr && [[ ! -s $TRACE && ! -s $WEB_TRACE ]]
  }
  explicit_gitea() {
    command git remote add other git@forge-alias:example/project.git
    command git config remote.other.forge gitea
    command git config remote.other.forgeWebUrl https://forge.invalid/git/example/project
    repo-open --remote other
    [[ $(<"$WEB_TRACE") == https://forge.invalid/git/example/project ]] || return
    repo-pr --remote other
    [[ $(<"$WEB_TRACE") == https://forge.invalid/git/example/project/compare/main...feature%2Ftopic ]]
  }
  invalid_fetch() {
    command git config --add remote.origin.url https://github.com/example/other.git
    reset_traces; ! repo-open && [[ ! -s $WEB_TRACE ]]
  }
  subpath_fetch() {
    command git remote add other https://forge.invalid/git/example/project.git
    command git config remote.other.forge gitea
    command git config remote.other.forgeWebUrl https://forge.invalid/git/example/project
    repo-pr --remote other
    [[ $(<"$WEB_TRACE") == https://forge.invalid/git/example/project/compare/main...feature%2Ftopic ]]
  }
  unsafe_input() {
    local REPLY candidate
    for candidate in "https://user:secret@forge.invalid/example/project" "https://github.com/example/project?query" "https://github.com/example/../project" "https://github.com/example/project/subpath"; do
      _repo_url_identity "$candidate" && return 1
    done
    reset_traces
    ! repo-open --remote "-bad" && [[ ! -s $WEB_TRACE ]]
  }
  missing_cli() {
    /bin/mkdir -p "$work/missing-bin" "$work/system-bin"
    export GH_SENTINEL="$work/system-gh-called"
    print -rl -- '#!/bin/sh' ': > "$GH_SENTINEL"' 'exit 99' > "$work/system-bin/gh"
    /bin/chmod +x "$work/system-bin/gh"
    /bin/ln -s "$work/bin/git" "$work/missing-bin/git"
    # Prove a system-like fallback exists, then exclude every non-allowlisted path.
    path=("$work/system-bin" /usr/bin /bin)
    rehash
    [[ ${commands[gh]} == "$work/system-bin/gh" ]] || return 1
    path=("$work/missing-bin")
    rehash
    (( ! $+commands[gh] )) || return 1
    repo-issues > "$work/missing" 2>&1 && return 1
    [[ $(<"$work/missing") == *"gh is not installed"* && ! -e $GH_SENTINEL && ! -s $GH_TRACE ]]
  }
  tea_setup() {
    command git remote add other git@forge-alias:example/project.git
    command git config remote.other.forge gitea
    command git config remote.other.forgeWebUrl https://forge.invalid/git/example/project
    command git config remote.other.forgeLogin fixture
  }
  tea_lists() {
    tea_setup
    repo-issues --remote other
    [[ $(<"$TEA_TRACE") == $'issues\nlist\n--repo\nexample/project\n--login\nfixture\n--fields\nindex,title,state' ]] || return
    repo-prs --remote other
    [[ $(<"$TEA_TRACE") == $'pulls\nlist\n--repo\nexample/project\n--login\nfixture\n--fields\nindex,title,state' ]]
  }
  tea_wrong_server() {
    tea_setup
    export TEA_LOGINS='[{"name":"fixture","url":"https://other.invalid/git"}]'
    reset_traces
    ! repo-issues --remote other && [[ ! -s $TEA_TRACE ]]
  }
  tea_wrong_subpath() {
    tea_setup
    export TEA_LOGINS='[{"name":"fixture","url":"https://forge.invalid/different"}]'
    reset_traces
    ! repo-prs --remote other && [[ ! -s $TEA_TRACE ]]
  }
  tea_bad_metadata() {
    tea_setup
    local candidate
    for candidate in 'invalid' '[]' '[{"name":"fixture","url":"https://forge.invalid/git"},{"name":"fixture","url":"https://forge.invalid/git"}]'; do
      export TEA_LOGINS=$candidate
      repo-issues --remote other && return 1
    done
    [[ ! -s $TEA_TRACE ]]
  }
  tea_existing_pr() {
    tea_setup
    export TEA_PULLS='[{"index":"23","base":"main","head":"feature/topic"}]'
    repo-pr --remote other
    [[ $(<"$WEB_TRACE") == https://forge.invalid/git/example/project/pulls/23 ]]
  }
  tea_fork_not_matching() {
    tea_setup
    export TEA_PULLS='[{"index":"23","base":"main","head":"different:feature/topic"}]'
    repo-pr --remote other
    [[ $(<"$WEB_TRACE") == https://forge.invalid/git/example/project/compare/main...feature%2Ftopic ]]
  }
  tea_unavailable_safe_browser() {
    tea_setup
    export TEA_FAILURE=1
    repo-pr --remote other
    [[ $(<"$WEB_TRACE") == https://forge.invalid/git/example/project/compare/main...feature%2Ftopic ]]
  }
  invalid_refs() {
    reset_traces
    ! repo-pr --base feature/topic && ! repo-pr --base '-bad' && ! repo-pr --force && [[ ! -s $TRACE && ! -s $WEB_TRACE ]]
  }
  listing() { repo-issues; [[ $(<"$GH_TRACE") == $'issue\nlist\n--repo\nhttps://github.com/example/project' ]]; }
  # Each test gets the same local config; no network command is executed.
  cp .git/config "$work/config"
  for item in github_open push_branch failed_push failed_browser existing_pr blocked_push mismatched_push multiple_push rewritten_push explicit_gitea invalid_fetch invalid_refs listing subpath_fetch unsafe_input tea_lists tea_wrong_server tea_wrong_subpath tea_bad_metadata tea_existing_pr tea_fork_not_matching tea_unavailable_safe_browser missing_cli; do
    cp "$work/config" .git/config
    reset_traces
    check "AK07_08_$item" "$item"
  done
  print "$passed passed, $failed failed"
  (( failed == 0 ))
)
