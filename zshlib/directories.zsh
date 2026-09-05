setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups

alias la='ls -A'
alias ll='ls -l'
alias lsa='ls -lah'


alias ..='cd ..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias cd/='cd /'

cd() {
  case "$*" in
    ...)    builtin cd ../.. ;;
    ....)   builtin cd ../../.. ;;
    .....)  builtin cd ../../../.. ;;
    ......)  builtin cd ../../../../.. ;;
    *)      builtin cd "$@" ;;
  esac
}

alias md='mkdir -p'


function mcd() {
  (( $# == 1 )) || { print -u2 "usage: mcd <directory>"; return 2; }
  command mkdir -p -- "$1" && builtin cd -- "$1"
}

rd() {
  emulate -L zsh
  [[ $1 == -- ]] && shift
  (( $# )) || { print -u2 'usage: rd [--] directory ...'; return 2; }
  local target resolved reply
  local -a targets
  for target in "$@"; do
    resolved=${target:A}
    # Reject roots and ancestors of the current directory or home before prompting.
    if [[ ! -d $target || -L $target || $resolved == / || ${resolved:h} == / ||
          $PWD == $resolved || $PWD == $resolved/* ||
          $HOME == $resolved || $HOME == $resolved/* ]]; then
      print -u2 'rd: unsafe or non-directory target rejected'
      return 1
    fi
    targets+=("$target")
  done
  print -n -- "Remove ${#targets} directories recursively? Type yes: "
  IFS= read -r reply || return 1
  [[ $reply == yes ]] || return 1
  command rm -rf -- "${targets[@]}" 2>/dev/null || {
    print -u2 'rd: removal failed'
    return 1
  }
}
