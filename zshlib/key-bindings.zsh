
bindkey -e

bindkey "^[[1;5C" forward-word   # Ctrl+Right
bindkey "^[[1;5D" backward-word  # Ctrl+Left
bindkey "^B"  backward-word
bindkey "^[b" backward-word
bindkey "^[f" forward-word

bindkey '^r'   history-incremental-search-backward
bindkey '^[[A' up-line-or-search    # Up arrow
bindkey '^[[B' down-line-or-search  # Down arrow

bindkey '^[[H'  beginning-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[OH'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[4~' end-of-line
bindkey '^[OF'  end-of-line

bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line

bindkey '^?'    backward-delete-char  # Backspace
bindkey '^[[3~' delete-char           # Del

bindkey '^[[Z' reverse-menu-complete  # Shift+Tab

bindkey ' '     magic-space          # history expansion on space
bindkey "^[m"   copy-prev-shell-word
bindkey '\C-x\C-e' edit-command-line  # edit command in $EDITOR
bindkey '\ew'   kill-region

run-with-sudo() { LBUFFER="sudo $LBUFFER" }
zle -N run-with-sudo
bindkey "^K" run-with-sudo
