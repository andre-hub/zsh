# No network access or repository changes on shell startup.
git_current_branch() {
  emulate -L zsh
  command git symbolic-ref --quiet --short HEAD 2>/dev/null ||
    command git rev-parse --short HEAD 2>/dev/null
}

# Each repository runs in a subshell: neither cd nor branch restoration leaks
# into the caller, and one failed repository does not stop the batch.
_gpa_one() (
  emulate -L zsh
  unsetopt err_exit
  local original upstream dirt worktrees remote merge_ref fetched
  local -a remotes merge_refs
  integer result=0 changed=0
  builtin cd -- "$1" || return 1
  original=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) || return 3
  command git show-ref --verify --quiet refs/heads/main 2>/dev/null || return 3
  upstream=$(command git rev-parse --symbolic-full-name 'main@{upstream}' 2>/dev/null) || return 3
  remotes=("${(@f)$(command git config --get-all branch.main.remote 2>/dev/null)}")
  merge_refs=("${(@f)$(command git config --get-all branch.main.merge 2>/dev/null)}")
  (( ${#remotes} == 1 && ${#merge_refs} == 1 )) || return 3
  remote=$remotes[1]; merge_ref=$merge_refs[1]
  [[ -n $remote && $merge_ref == refs/heads/* ]] || return 3
  command git check-ref-format "$merge_ref" >/dev/null 2>&1 || return 3
  dirt=$(command git status --porcelain --untracked-files=all 2>/dev/null) || return 1
  [[ -z $dirt ]] || return 3
  worktrees=$(command git worktree list --porcelain 2>/dev/null) || return 1
  if [[ $original != main && $'\n'$worktrees$'\n' == *$'\nbranch refs/heads/main\n'* ]]; then
    return 3
  fi
  {
    if [[ $original != main ]]; then
      command git checkout --quiet --no-overwrite-ignore main >/dev/null 2>&1 || return 1
      changed=1
    fi
    dirt=$(command git status --porcelain --untracked-files=all 2>/dev/null) || return 1
    [[ -z $dirt ]] || return 1
    # pull cannot protect ignored files; fetch the exact upstream, then use
    # merge's no-overwrite guard (still strictly fast-forward, never autostash).
    if command git fetch --no-tags --no-recurse-submodules -- "$remote" "$merge_ref" >/dev/null 2>&1; then
      fetched=$(command git rev-parse --verify 'FETCH_HEAD^{commit}' 2>/dev/null) || return 1
      command git -c merge.autoStash=false merge --ff-only --no-overwrite-ignore -- "$fetched" >/dev/null 2>&1 || result=1
    else
      result=1
    fi
  } always {
    if (( changed )); then
      if ! command git checkout --quiet --no-overwrite-ignore "$original" >/dev/null 2>&1; then
        print -u2 'gpa: original branch could not be restored'
        result=1
      fi
    fi
  }
  return $result
)

gpa() {
  emulate -L zsh
  unsetopt err_exit
  (( $# == 0 )) || { print -u2 'usage: gpa'; return 2; }
  local directory
  integer succeeded=0 skipped=0 failed=0 result index=0
  for directory in ./*(ND/); do
    [[ ! -L $directory && ( -d $directory/.git || -f $directory/.git ) ]] || continue
    (( ++index ))
    _gpa_one "$directory"
    result=$?
    case $result in
      0) (( ++succeeded )) ;;
      3) (( ++skipped )); print -r -- "gpa: repository $index skipped" ;;
      *) (( ++failed )); print -u2 -- "gpa: repository $index failed" ;;
    esac
  done
  print -r -- "gpa: $succeeded updated; $skipped skipped; $failed failed"
  (( failed == 0 ))
}
