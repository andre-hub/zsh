#!/usr/bin/env zsh
emulate -LR zsh
setopt err_exit no_unset pipe_fail
root=${0:A:h:h}
work=$(mktemp -d "$root/tests/.git-navigation.XXXXXXXX")
trap '/bin/rm -rf -- "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
(
export HOME="$work/home" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_CONFIG_COUNT GIT_CONFIG_PARAMETERS GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES
mkdir -p "$HOME" "$work/batch" "$work/bin"
source "$root/zshlib/git.zsh"
source "$root/zshlib/directories.zsh"
source "$root/zshlib/aliases.zsh"
integer passed=0
check() {
  local label=$1
  shift
  if "$@" >"$work/output" 2>&1; then
    (( ++passed )); print -r -- "ok - $label"
  else
    print -r -- "not ok - $label"
    return 1
  fi
}
expect_aliases() {
  [[ $aliases[g] == git && $aliases[gco] == 'git commit' &&
     $aliases[gfe] == 'git fetch --all --tags --prune' &&
     $aliases[gps] == 'git push' && $aliases[gpl] == 'git pull --ff-only' &&
     $aliases[gst] == 'git status -sb' && $aliases[gaa] == 'git add .' &&
     $aliases[gbr] == 'git branch' && $aliases[gif] == 'git diff' ]] || return 1
  local old
  for old in ga gc gss gd grb d pu po l sl; do
    (( ! ${+aliases[$old]} )) || return 1
  done
  [[ $aliases[....] == 'cd ../../..' && $aliases[md] == 'mkdir -p' ]]
}
check 'AK04_ReducedAliases_ExactDefinitions' expect_aliases
source "$root/zshplugins/git-alias.plugin.zsh"
check 'AK04_Plugin_DoesNotRestoreOldAliases' expect_aliases
check_alias_execution() {
  cat > "$work/bin/git" <<'STUB'
#!/bin/sh
printf '%s\n' "$@" > "$GIT_TEST_ARGV"
STUB
  chmod +x "$work/bin/git"
  export GIT_TEST_ARGV="$work/argv"
  local -a saved_path=("$path[@]")
  path=("$work/bin" "$path[@]")
  local shortcut actual expected
  for shortcut in g gco gfe gps gpl gst gaa gbr gif; do
    eval "$shortcut" || return 1
    actual=$(<"$GIT_TEST_ARGV")
    expected=${aliases[$shortcut]#git}
    expected=${expected# }
    [[ ${actual//$'\n'/ } == $expected ]] || return 1
  done
  path=("$saved_path[@]")
  rm "$work/bin/git"
}
check 'AK04_AliasCalls_ExactGitArguments' check_alias_execution

# Synthetic commit identities contain no personal names or addresses.
command git init --bare --initial-branch=main "$work/upstream" >/dev/null 2>&1
command git init --initial-branch=main "$work/seed" >/dev/null 2>&1
command git -C "$work/seed" -c user.name=fixture -c user.email=fixture commit --allow-empty -m initial >/dev/null 2>&1
command git -C "$work/seed" remote add origin "$work/upstream"
command git -C "$work/seed" push origin main >/dev/null 2>&1
clone() { command git clone --quiet "$work/upstream" "$1" 2>/dev/null; }
clone "$work/batch/a feature"
command git -C "$work/batch/a feature" checkout -qb feature
clone "$work/batch/b dirty"
print dirty > "$work/batch/b dirty/untracked"
clone "$work/batch/c detached"
command git -C "$work/batch/c detached" checkout -q --detach
clone "$work/batch/d no upstream"
command git -C "$work/batch/d no upstream" branch --unset-upstream
clone "$work/batch/e no main"
command git -C "$work/batch/e no main" branch -m alternate
clone "$work/batch/f worktree"
command git -C "$work/batch/f worktree" checkout -qb feature
command git -C "$work/batch/f worktree" worktree add -q "$work/other-worktree" main
clone "$work/batch/g divergent"
command git -C "$work/batch/g divergent" -c user.name=fixture -c user.email=fixture commit --allow-empty -m divergent >/dev/null 2>&1
command git -C "$work/batch/g divergent" checkout -qb feature
clone "$work/batch/h after failure"
mkdir "$work/batch/nested"
clone "$work/batch/nested/deep"
old=$(command git -C "$work/seed" rev-parse HEAD)
command git -C "$work/seed" -c user.name=fixture -c user.email=fixture commit --allow-empty -m update >/dev/null 2>&1
command git -C "$work/seed" push origin main >/dev/null 2>&1
new=$(command git -C "$work/seed" rev-parse HEAD)
check_batch() {
  builtin cd "$work/batch"
  local initial=$PWD output rc
  output=$(gpa); rc=$?
  (( rc == 1 )) || return 1
  [[ $output == *'2 updated; 5 skipped; 1 failed'* && $PWD == $initial ]] || return 1
  [[ $(command git -C 'a feature' rev-parse main) == $new ]] || return 1
  [[ $(command git -C 'a feature' branch --show-current) == feature ]] || return 1
  [[ $(command git -C 'g divergent' branch --show-current) == feature ]] || return 1
  [[ $(command git -C 'h after failure' rev-parse main) == $new ]] || return 1
  local repository
  for repository in 'b dirty' 'c detached' 'd no upstream' 'f worktree' nested/deep; do
    [[ $(command git -C "$repository" rev-parse main) == $old ]] || return 1
  done
}
check 'AK05_AK06_Batch_FFSkipsDivergenceRestoreAndContinue' check_batch
check_rd() {
  builtin cd "$work"
  mkdir 'remove one' 'remove two'
  print data > 'remove one/file'
  rd 'remove one' 'remove two' <<< no && return 1
  [[ -e 'remove one/file' && -d 'remove two' ]] || return 1
  rd / <<< yes && return 1
  rd "$HOME" <<< yes && return 1
  rd . <<< yes && return 1
  ln -s 'remove one' linked
  rd linked <<< yes && return 1
  rd 'remove one' 'remove two' <<< yes || return 1
  [[ ! -e 'remove one' && ! -e 'remove two' ]]
}
check_restore_failure() {
  clone "$work/restore-case" || return 1
  command git -C "$work/restore-case" checkout -qb feature || return 1
  export REAL_GIT=$commands[git]
  cat > "$work/bin/git" <<'STUB'
#!/bin/sh
if [ "$1" = checkout ] && [ "$2" = --quiet ] && [ "$4" = feature ] && [ "${FAIL_RESTORE:-0}" = 1 ]; then exit 42; fi
if [ "$1" = -c ]; then exit 41; fi
exec "$REAL_GIT" "$@"
STUB
  chmod +x "$work/bin/git"
  local -a saved_path=("$path[@]")
  path=("$work/bin" "$path[@]")
  local output rc
  output=$(_gpa_one "$work/restore-case" 2>&1); rc=$?
  (( rc == 1 )) || return 1
  [[ $(command git -C "$work/restore-case" branch --show-current) == feature ]] || return 1
  export FAIL_RESTORE=1
  output=$(_gpa_one "$work/restore-case" 2>&1); rc=$?
  (( rc == 1 )) || return 1
  [[ $output == *'original branch could not be restored'* ]] || return 1
  [[ $(command git -C "$work/restore-case" branch --show-current) == main ]] || return 1
  unset FAIL_RESTORE
  path=("$saved_path[@]")
}
check 'AK06_PullFailure_RestoreAndVisibleRestorationFailure' check_restore_failure
check 'AK09_Rd_OneConfirmationCancellationAndDangerousTargets' check_rd
check_mcd() {
  mcd "$work/new folder" || return 1
  [[ $PWD == "$work/new folder" ]] || return 1
  print data > file
  mcd file/child && return 1
  [[ $PWD == "$work/new folder" ]]
}
check 'AK09_Mcd_PreservesDirectoryOnFailure' check_mcd
# Real local remotes reproduce both destructive ignored-file transitions.
check_ignored_collision() {
  local mode=$1 shape=$2 case_root="$work/ignored-$1-$2" relative old_main expected_branch=main output rc
  mkdir -p "$case_root/batch" || return
  command git init --bare --initial-branch=main "$case_root/upstream" >/dev/null 2>&1 || return
  command git init --initial-branch=main "$case_root/seed" >/dev/null 2>&1 || return
  print 'cache*' > "$case_root/seed/.gitignore"
  command git -C "$case_root/seed" add .gitignore || return
  command git -C "$case_root/seed" -c user.name=fixture -c user.email=fixture commit -qm ignore || return
  command git -C "$case_root/seed" remote add origin "$case_root/upstream" || return
  command git -C "$case_root/seed" push -q origin main 2>/dev/null || return
  command git clone -q "$case_root/upstream" "$case_root/batch/repo" 2>/dev/null || return
  relative=cache.dat
  [[ $shape == nested ]] && relative=cache/nested/item
  mkdir -p "${case_root}/seed/${relative:h}" || return
  print upstream-data > "$case_root/seed/$relative"
  command git -C "$case_root/seed" add -f -- "$relative" || return
  command git -C "$case_root/seed" -c user.name=fixture -c user.email=fixture commit -qm incoming || return
  command git -C "$case_root/seed" push -q origin main 2>/dev/null || return
  if [[ $mode == checkout ]]; then
    expected_branch=feature
    command git -C "$case_root/batch/repo" checkout -qb feature || return
    command git -C "$case_root/batch/repo" fetch -q origin 2>/dev/null || return
    command git -C "$case_root/batch/repo" update-ref refs/heads/main refs/remotes/origin/main || return
  fi
  old_main=$(command git -C "$case_root/batch/repo" rev-parse main) || return
  mkdir -p "${case_root}/batch/repo/${relative:h}" || return
  print local-data > "$case_root/batch/repo/$relative"
  builtin cd "$case_root/batch" || return
  output=$(gpa); rc=$?
  (( rc == 1 )) || return 1
  [[ $output == *'0 updated; 0 skipped; 1 failed'* ]] || return 1
  [[ $(<"repo/$relative") == local-data ]] || return 1
  [[ $(command git -C repo branch --show-current) == $expected_branch ]] || return 1
  [[ $(command git -C repo rev-parse main) == $old_main ]]
}
check 'GF01_Checkout_IgnoredFilePreserved' check_ignored_collision checkout flat
check 'GF01_Checkout_IgnoredNestedFilePreserved' check_ignored_collision checkout nested
check 'GF01_FastForward_IgnoredFilePreserved' check_ignored_collision merge flat
check 'GF01_FastForward_IgnoredNestedFilePreserved' check_ignored_collision merge nested
check_ignored_noncollision() {
  local case_root="$work/ignored-merge-nested" output
  # Retain unrelated ignored build output, remove only our colliding fixture.
  rm "$case_root/batch/repo/cache/nested/item" || return
  print build-data > "$case_root/batch/repo/cache/build-output"
  builtin cd "$case_root/batch" || return
  output=$(gpa) || return
  [[ $output == *'1 updated; 0 skipped; 0 failed'* ]] || return 1
  [[ $(<repo/cache/build-output) == build-data && $(<repo/cache/nested/item) == upstream-data ]]
}
check 'GF01_NoncollidingIgnoredBuildOutput_AllowsUpdate' check_ignored_noncollision
check_exact_upstream() {
  local case_root="$work/ignored-merge-nested" original_main release_tip output
  original_main=$(command git -C "$case_root/seed" rev-parse main) || return
  command git -C "$case_root/seed" checkout -qb release || return
  command git -C "$case_root/seed" -c user.name=fixture -c user.email=fixture commit --allow-empty -qm release || return
  command git -C "$case_root/seed" push -q origin release 2>/dev/null || return
  release_tip=$(command git -C "$case_root/seed" rev-parse release) || return
  command git -C "$case_root/batch/repo" fetch -q origin release:refs/remotes/origin/release 2>/dev/null || return
  command git -C "$case_root/batch/repo" config branch.main.merge refs/heads/release || return
  builtin cd "$case_root/batch" || return
  output=$(gpa) || return
  [[ $output == *'1 updated; 0 skipped; 0 failed'* ]] || return 1
  [[ $(command git -C repo rev-parse main) == $release_tip ]] || return 1
  [[ $(command git -C repo rev-parse origin/main) == $original_main ]]
}
check 'GF01_Fetch_UsesConfiguredUpstreamNotGuessedMain' check_exact_upstream


print -r -- "$passed passed; 0 failed"
)
