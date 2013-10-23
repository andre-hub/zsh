###########         Aliases         ###########

# Push and pop directories on directory stack
alias pu='pushd'
alias po='popd'

# Super user
alias _='sudo'

#alias g='grep -in'

# Show history
alias history='fc -l 1'

# List direcory contents
alias lsa='ls -lah'
alias l='ls -la'
alias ll='ls -l'
alias sl=ls # often screw this up

alias afind='ack-grep -il'

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
fi

# some more ls aliases
alias -g '...'='../..'
alias -g '....'='../../..'
alias -g '.....'='../../../..'
alias -- -='cd -'
alias sl="ls"
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias rd="rm -irf"
alias ht="htop"
alias rsync="rsync --human-readable  --progress --recursive -t"

# starte Programm
alias -s txt='nano'
alias -s conf='nano'
alias -s cnf='nano'


hash -d RC=/etc/rc.d/               # executed files from init (Slackware)
hash -d RC=/etc/conf.d/             # Init-Files from init (Gentoo)
hash -d RC=/etc/init.d/             # executed files from init (Gentoo, Debian, ..)

alias insecssh='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'

alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"