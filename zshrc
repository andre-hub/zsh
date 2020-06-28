###############################################

###########      Start/Loader       ###########
# Helper; will be unset later.
_exists() { (( $+commands[$1] )) }

# plugins
# archlinux battery colored-man-pages cygwin debian fzf-completion fzf-key-bindings 
# git-alias github git golang go-templates gpg-agent mercurial ssh-agent svn tmux 
# vi-mode xfce
plugins=(debian xfce git git-alias github battery colored-man-pages golang tmux fzf-completion fzf-key-bindings sql)

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Load and run compinit
autoload -U compinit
autoload -U add-zsh-hook
autoload -Uz vcs_info
compinit -i

###########         setopt          ###########
setopt autocd
setopt share_history
setopt correct
setopt rmstarwait
setopt APPEND_HISTORY
setopt nobeep
setopt interactivecomments
setopt HISTFINDNODUPS

# Allow for functions in the prompt.
setopt PROMPT_SUBST

# enable programmable completion features
if [ -f /etc/zsh_completion ]; then
    . /etc/	
fi

zstyle ':vcs_info:*' enable git

###########      load plugins       ###########
# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if [ -d $plugin ]; then
    fpath=($plugin $fpath)
  fi
done

# include all libs
for config_file (~/.zshlib/*.zsh); do
    source $config_file
done

# Load all of the plugins that were defined in ~/.zshrc
for pluginfiles ($plugins); do
    source ~/.zshplugins/$pluginfiles.plugin.zsh
done

###########          EXPORT          ###########
export COLORTERM="yes"
export EDITOR="vim"  # i like vim, sublinetext3, ee

if [ -f ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
        print "Note: ~/.zsh-syntax-highlighting/ is not available."
fi

###########       Load include       ###########
typeset -U path  # No duplicates
path=()

_prepath() {
    for dir in "$@"; do
        dir=${dir:A}
        [[ ! -d "$dir" ]] && return
        path=("$dir" $path[@])
    done
}
_postpath() {
    for dir in "$@"; do
        dir=${dir:A}
        [[ ! -d "$dir" ]] && return
        path=($path[@] "$dir")
    done
}

_prepath /bin /sbin /usr/bin /usr/sbin  /usr/games
_prepath /usr/pkg/bin   /usr/pkg/sbin   # NetBSD
_prepath /usr/X11R6/bin /usr/X11R6/sbin # OpenBSD
_prepath /usr/local/bin /usr/local/sbin

_prepath "$HOME/workspace/go/bin"      # Go
_prepath "$HOME/.local/bin"            # My local stuff.
if [[ -d "$HOME/.gem/ruby" ]]; then    # Ruby
    for d in "$HOME/.gem/ruby/"*; do
        _postpath "$d/bin";
    done
fi

unfunction _prepath
unfunction _postpath


if [ -f ~/.zshsecinclude ]; then
    source ~/.zshsecinclude
else
    print "Note: ~/.zshsecinclude is not available."
fi

###########          TMUX            ###########
if [ -z "$TMUX" ] && [ $TERM != "screen" ] && [ "$SSH_CONNECTION" != "" ]; then
  WHOAMI=$(whoami)
  if tmux has-session -t $WHOAMI 2>/dev/null; then
    tmux -2 attach-session -t $WHOAMI
  else
    tmux -2 new-session -s $WHOAMI
  fi
fi

###########   Directory shortcuts   ###########
hash -d wit=$HOME/workspace/it
hash -d dt=$HOME/Downloads/Temp

###########   aliases   ###########
_exists htop       && alias top='htop'

alias Y='echo $(date +%Y-%m-%d)'
alias YY=`date +%Y-%m-%d_%H-%M-%S`

###########   Selfmade Login Intro   ###########
uptimestart=`uptime | colrm 1 13 | colrm 6`
print "$fg[red]Host: $fg[green]$HOST$fg[red], Zeit: $fg[green]`date +%d.%m.%Y' '%H:%M:%S`$fg[red], Up: $fg[green]$uptimestart"
print "$fg[red]Term: $fg[green]$TTY $fg[red], $fg[red]Shell: $fg[green]Zsh $ZSH_VERSION $fg[red] (PID=$$)"
print "$fg[red]Login: $fg[green]$LOGNAME $fg[red] (UID=$EUID), cars: $fg[green]$COLUMNS x $LINES"

PROMPT='%n@%m:%~%  # '
() {
    local formats="${PRCH[branch]} %b%c%u"
    local actionformats="${formats}%{${fg[default]}%} ${PRCH[sep]} %{${fg[green]}%}%a"
    zstyle ':vcs_info:*:*' formats           $formats
    zstyle ':vcs_info:*:*' actionformats     $actionformats
    zstyle ':vcs_info:*:*' stagedstr         "%{${fg[green]}%}${PRCH[circle]}"
    zstyle ':vcs_info:*:*' unstagedstr       "%{${fg[yellow]}%}${PRCH[circle]}"
    zstyle ':vcs_info:*:*' check-for-changes true
}

add-zsh-hook precmd vcs_info

#RPROMPT='${vcs_info_msg_0_}'

# Unset helper.
unfunction _exists