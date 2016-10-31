# Changing/making/removing directory
setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups

# List direcory contents
alias l='ls'
alias la='ls -A'
alias ll='ls -l'
alias lsa='ls -lah'
alias sl=ls # often screw this up

# Push and pop directories on directory stack
alias pu='pushd'
alias po='popd'

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
fi

alias ..='cd ..'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias ...='cd...'
alias ....='cd....'
alias .....='cd.....'
alias cd/='cd /'

cd () {
  if   [[ "x$*" == "x..." ]]; then
    cd ../..
  elif [[ "x$*" == "x...." ]]; then
    cd ../../..
  elif [[ "x$*" == "x....." ]]; then
    cd ../../..
  elif [[ "x$*" == "x......" ]]; then
    cd ../../../..
  else
    builtin cd "$@"
  fi
}

alias rd="rm -irf"
alias md='mkdir -p'
alias d='dirs -v'

# mkdir & cd to it
function mcd() { 
  mkdir -p "$1" && cd "$1"; 
}