# Self-contained replacements for the earlier fzf widgets; no external loader.
# Ctrl-T: insert paths; Alt-C: change directory; Ctrl-R: recall history.
[[ -o interactive && ${TERM:-dumb} != dumb ]] || return 0
(( $+commands[fzf] )) || return 0

fzf-file-widget() {
  emulate -L zsh
  # fzf may finish before find: a producer SIGPIPE must not discard its selection.
  setopt localoptions no_pipefail
  local selected item
  selected=$(
    command find . -name .git -prune -o -type f -print0 -o -type d -print0 |
      command fzf --read0 --print0 --height 40% --reverse --multi
    local -a result=( "${pipestatus[@]}" )
    (( result[2] == 0 && (result[1] == 0 || result[1] == 141) ))
  ) || return 0
  for item in "${(@0)selected}"; do
    [[ -n $item ]] && LBUFFER+="${(q)item} "
  done
  zle redisplay
}
fzf-cd-widget() {
  emulate -L zsh
  setopt localoptions no_pipefail
  local selected
  selected=$(
    command find . -name .git -prune -o -type d -print0 |
      command fzf --read0 --print0 --height 40% --reverse --no-multi
    local -a result=( "${pipestatus[@]}" )
    (( result[2] == 0 && (result[1] == 0 || result[1] == 141) ))
  ) || return 0
  selected=${selected%$'\0'}
  [[ -n $selected ]] && builtin cd -- "$selected"
  zle reset-prompt
}
fzf-history-widget() {
  emulate -L zsh
  setopt localoptions no_pipefail
  local selected number
  selected=$(
    builtin fc -rl 1 | command fzf --height 40% --no-multi --query "$LBUFFER"
    local -a result=( "${pipestatus[@]}" )
    (( result[2] == 0 && (result[1] == 0 || result[1] == 141) ))
  ) || return 0
  number=${${(z)selected}[1]}
  [[ $number == <-> ]] && zle vi-fetch-history -n "$number"
  zle redisplay
}
zle -N fzf-file-widget
zle -N fzf-cd-widget
zle -N fzf-history-widget
# Bind both maps so vi-mode may be loaded before or after this plugin.
bindkey -M emacs '^T' fzf-file-widget
bindkey -M viins '^T' fzf-file-widget
bindkey -M emacs '\ec' fzf-cd-widget
bindkey -M viins '\ec' fzf-cd-widget
bindkey -M emacs '^R' fzf-history-widget
bindkey -M viins '^R' fzf-history-widget
