# Vi editing, without replacing signal handlers or existing ZLE hooks.
[[ -o interactive && ${TERM:-dumb} != dumb ]] || return 0
bindkey -v
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line
bindkey -M viins '^P' up-history
bindkey -M viins '^N' down-history
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
# Do not replace an explicitly installed fuzzy history binding.
if [[ $(bindkey -M viins '^R') != *fzf-history-widget ]]; then
  bindkey -M viins '^R' history-incremental-search-backward
fi
