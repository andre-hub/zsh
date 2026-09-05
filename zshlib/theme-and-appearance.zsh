# Built-in prompt: no external theme, command substitution or host configuration.
autoload -U colors && colors
export LSCOLORS='Gxfxcxdxbxegedabagacad'
if [[ ${DISABLE_LS_COLORS:-false} != true && $TERM != dumb ]]; then
  case $OSTYPE in
    linux*) alias ls='ls --color=auto' ;;
    freebsd*|darwin*) alias ls='ls -G' ;;
  esac
fi
setopt auto_cd multios
unsetopt prompt_subst
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '
