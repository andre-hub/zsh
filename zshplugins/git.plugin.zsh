GIT_PROMPT_EXECUTABLE='python'

# Aliases
alias git='LANG=en_US.UTF-8 git'
alias g='git'
compdef g=git
alias gaa='git aa'
compdef _git gpl=git-add
alias gad='git ad'
compdef _git gpl=git-add
alias gau='git au'
compdef _git gpl=git-add
alias gbr='git br'
compdef _git gbr=git-branch
alias gca='git ca'
compdef _git gca=git-commit
alias gch='git ch'
compdef _git gch=git-checkout
alias gco='git co -v'
compdef _git gc=git-commit
alias gfe='git fe'
compdef _git gpl=git-fetch
alias gpl='git pl'
compdef _git gpl=git-pull
alias gps='git ps'
compdef _git gps=git-push
alias grb='git rb'
compdef _git gpl=git-rebase
alias grc='git rb --continue'
compdef _git grc=git-rebase

alias gst='git st'
compdef _git gst=git-status
alias gss='git status -s'
compdef _git gss=git-status
gdv() { git diff -w "$@" | view - }

alias glg='g lg'
compdef _git gpl=git-log
alias glg='git log --stat --max-count=5'
compdef _git glg=git-log
alias glgg='git log --graph --max-count=5'
compdef _git glgg=git-log
alias gcount='git shortlog -sn'
compdef _gcount=git

alias gmt='git mergetool'
compdef _git gpl=git-mergetool
alias gmg='git merge'
compdef _git gmg=git-merge

alias gua='gitg'
compdef _gitg gitg=gitg
alias gif='git diff'
compdef _git gif=git-diff
alias gfp='git fetch --all --tags --prune'
compdef _git gfp=git-fetch
alias gfr='git fetch --all && git rebase'
compdef _git gfr=git-fetch
alias gcp='git cherry-pick'
compdef _git gcp=git-cherry-pick
alias grh='git reset HEAD'
compdef _git grh=git
alias grhh='git reset HEAD --hard'
compdef _git grhh=git

# Git and svn mix
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'
compdef git-svn-dcommit-push=git
alias gsr='git svn rebase'
compdef _git gsr=git-svn
alias gsd='git svn dcommit'
compdef _git gsd=git-svn

# these aliases take advantage of the previous function
alias ggpull='git pull origin $(current_branch)'
compdef ggpull=git
alias ggpush='git push origin $(current_branch)'
compdef ggpush=git
alias ggpnp='git pull origin $(current_branch) && git push origin $(current_branch)'
compdef ggpnp=git

export __GIT_PROMPT_DIR=${0:A:h}
export GIT_PROMPT_EXECUTABLE=${GIT_PROMPT_USE_PYTHON:-"python"}

# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

## Function definitions
function preexec_update_git_vars() {
    case "$2" in
        git*|hub*|gh*|stg*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ] || [ ! -n "$ZSH_THEME_GIT_PROMPT_CACHE" ]; then
        update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function chpwd_update_git_vars() {
    update_current_git_vars
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS

    if [[ "$GIT_PROMPT_EXECUTABLE" == "python" ]]; then
        local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
        _GIT_STATUS=`python ${gitstatus} 2>/dev/null`
    fi
    if [[ "$GIT_PROMPT_EXECUTABLE" == "haskell" ]]; then
        local gitstatus="$__GIT_PROMPT_DIR/dist/build/gitstatus/gitstatus"
        _GIT_STATUS=`${gitstatus}`
    fi
    __CURRENT_GIT_STATUS=("${(@f)_GIT_STATUS}")
	GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
	GIT_AHEAD=$__CURRENT_GIT_STATUS[2]
	GIT_BEHIND=$__CURRENT_GIT_STATUS[3]
	GIT_STAGED=$__CURRENT_GIT_STATUS[4]
	GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
	GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
	GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
}

git_super_status() {
	precmd_update_git_vars
    if [ -n "$__CURRENT_GIT_STATUS" ]; then
	  STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$ZSH_THEME_GIT_PROMPT_BRANCH$GIT_BRANCH%{${reset_color}%}"
	  if [ "$GIT_BEHIND" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND$GIT_BEHIND%{${reset_color}%}"
	  fi
	  if [ "$GIT_AHEAD" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD$GIT_AHEAD%{${reset_color}%}"
	  fi
	  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR"
	  if [ "$GIT_STAGED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED%{${reset_color}%}"
	  fi
	  if [ "$GIT_CONFLICTS" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS%{${reset_color}%}"
	  fi
	  if [ "$GIT_CHANGED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$GIT_CHANGED%{${reset_color}%}"
	  fi
	  if [ "$GIT_UNTRACKED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED%{${reset_color}%}"
	  fi
	  if [ "$GIT_CHANGED" -eq "0" ] && [ "$GIT_CONFLICTS" -eq "0" ] && [ "$GIT_STAGED" -eq "0" ] && [ "$GIT_UNTRACKED" -eq "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
	  fi
	  STATUS="$STATUS%{${reset_color}%}$ZSH_THEME_GIT_PROMPT_SUFFIX"
	  echo "$STATUS"
	fi
}

# Default values for the appearance of the prompt. Configure at will.
ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[red]%}%{ ● %G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{ ✖ %G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[blue]%}%{ ✚ %G%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{ ↓ %G%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{ ↑ %G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{ … %G%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{ ✔ %G%}"