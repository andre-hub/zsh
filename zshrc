###############################################

###########      Start/Loader       ###########
#plugins=(archlinux debian mercurial vi-mode battery github gnu-utils ssh-agent xfce cygwin git gpg-agent svn)
plugins=(debian xfce ssh-agent git github git-alias)
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
autoload -U add-zsh-hook
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
    . /etc/zsh_completion
fi

###########      load plugins       ###########

# Load all of the plugins that were defined in ~/.zshrc
for pluginfiles ($plugins); do
    source ~/.zshplugins/$pluginfiles.plugin.zsh
done

# include all libs
for config_file (~/.zshlib/*.zsh); do
    source $config_file
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
if [ -f ~/.zshsecinclude ]; then
    source ~/.zshsecinclude
else
    print "Note: ~/.zshsecinclude is not available."
fi

###########          TMUX            ###########
if [ -z "$TMUX" ] && [ $TERM != "screen" ]; then
   tmux attach -d
   [ $? -eq 0 ] && exit
fi

###########   Selfmade Login Intro   ###########
uptimestart=`uptime | colrm 1 13 | colrm 6`
print "$fg[red]Host: $fg[green]$HOST$fg[red], Zeit: $fg[green]`date +%d.%m.%Y' '%H:%M:%S`$fg[red], Up: $fg[green]$uptimestart"
print "$fg[red]Term: $fg[green]$TTY $fg[red], $fg[red]Shell: $fg[green]Zsh $ZSH_VERSION $fg[red] (PID=$$)"
print "$fg[red]Login: $fg[green]$LOGNAME $fg[red] (UID=$EUID), cars: $fg[green]$COLUMNS x $LINES"

PROMPT='%n@%m:%3~% # '
RPROMPT='$(git_super_status)%{$reset_color%}'