###############################################
###########           ZSH           ###########
###############################################

###########      Start/Loader       ###########
plugins=(archlinux github ssh-agent gnu-utils gpg-agent vi-mode git-flow mercurial git package)
zshlib="~/.zshlib"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if [ -d $plugin ]; then
    fpath=($plugin $fpath)
  fi
done

# Load and run compinit
autoload -U compinit
compinit -i

# include all libs
for config_file (~/.zshlib/*.zsh) source $config_file

# Load all of the plugins that were defined in ~/.zshrc
for pluginfiles ($plugins); do
    source ~/.zshplugins/$pluginfiles.plugin.zsh
done

if [ -f ~/.zshsecinclude ]; then
    source ~/.zshsecinclude
else
    print "Note: ~/.zshsecinclude is not available."
fi

###########         setopt          ###########

setopt autocd
setopt share_history
setopt correct
setopt rmstarwait
setopt APPEND_HISTORY
setopt nobeep
setopt interactivecomments
setopt HISTFINDNODUPS
setopt HISTFINDNODUPS

# enable programmable completion features
if [ -f /etc/zsh_completion ]; then
    . /etc/zsh_completion
fi

###########          EXPORT          ###########

export COLORTERM="yes"
export EDITOR="nano"  # i like sublinetext2, gedit, ee


if [ -f ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
        print "Note: ~/.zsh-syntax-highlighting/ is not available."
fi

###########   Selfmade Login Intro   ###########
uptimestart=`uptime | colrm 1 13 | colrm 6`
print "$fg[red]Host: $fg[green]$HOST$fg[red], Zeit: $fg[green]`date +%d.%m.%Y' '%H:%M:%S`$fg[red], Up: $fg[green]$uptimestart"
print "$fg[red]Term: $fg[green]$TTY $fg[red], $fg[red]Shell: $fg[green]Zsh $ZSH_VERSION $fg[red] (PID=$$)"
print "$fg[red]Login: $fg[green]$LOGNAME $fg[red] (UID=$EUID), cars: $fg[green]$COLUMNS x $LINES"
