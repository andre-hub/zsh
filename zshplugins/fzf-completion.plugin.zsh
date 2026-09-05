# Self-contained path completion: type a path followed by ** and press Tab.
# No eval, shell-command options, host discovery, temporary files or loaders.
[[ -o interactive && ${TERM:-dumb} != dumb ]] || return 0
(( $+commands[fzf] )) || return 0

fzf-completion() {
  emulate -L zsh
  # fzf may finish before find: a producer SIGPIPE must not discard its selection.
  setopt localoptions no_pipefail
  local trigger=${FZF_COMPLETION_TRIGGER:-'**'} token prefix base query selected item head
  local -a tokens find_args
  tokens=( ${(z)LBUFFER} )
  token=${tokens[-1]-}
  if (( ${#tokens} < 2 )) || [[ $token != *"$trigger" || $LBUFFER != *"$trigger" ]]; then
    zle expand-or-complete
    return
  fi
  head=${LBUFFER[1,$(( ${#LBUFFER} - ${#token} ))]}
  prefix=${(Q)${token%"$trigger"}}
  # Expand only literal ~/; never execute or glob an entered expression.
  [[ $prefix == '~/'* ]] && prefix=$HOME/${prefix#\~/}
  if [[ -d $prefix ]]; then
    base=$prefix
    query=''
  elif [[ $prefix == */* ]]; then
    base=${prefix:h}
    query=${prefix:t}
  else
    base=.
    query=$prefix
  fi
  [[ -d $base ]] || { zle expand-or-complete; return; }
  [[ $base == /* || $base == ./* ]] || base=./$base
  find_args=( -name .git -prune -o -type d -print0 )
  [[ ${tokens[1]} == (cd|pushd|rmdir) ]] || find_args+=( -o -type f -print0 -o -type l -print0 )
  selected=$(
    command find "$base" "${find_args[@]}" |
      command fzf --read0 --print0 --height 40% --reverse --no-multi --query "$query"
    local -a result=( "${pipestatus[@]}" )
    (( result[2] == 0 && (result[1] == 0 || result[1] == 141) ))
  ) || return 0
  item=${selected%$'\0'}
  [[ -n $item ]] && LBUFFER="$head${(q)item} "
  zle redisplay
}
zle -N fzf-completion
bindkey -M emacs '^I' fzf-completion
bindkey -M viins '^I' fzf-completion
