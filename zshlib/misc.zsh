autoload -U url-quote-magic
zle -N self-insert url-quote-magic

bindkey "^[m" copy-prev-shell-word

setopt long_list_jobs
