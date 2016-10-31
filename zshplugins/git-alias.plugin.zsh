alias git='LANG=en_US.UTF-8 git'
alias g='git'
compdef g=git
alias gaa='git aa'
compdef _git gaa=git-add
alias gbr='git br'
compdef _git gbr=git-branch
alias gch='git ch'
compdef _git gch=git-checkout
alias gco='git co'
compdef _git gc=git-commit
alias gfe='git fe'
compdef _git gpl=git-fetch
alias gpl='git pl'
compdef _git gpl=git-pull
alias gps='git ps'
compdef _git gps=git-push
alias grb='git rb'
compdef _git grb=git-rebase
alias grbc='git rbc --continue'
compdef _git grb=git-rebase
alias gcl='git clone'
compdef git _gcl=git-clone
alias gst='git st'
compdef _git gst=git-status
alias gss='git status -s'
compdef _git gss=git-status
gdv() { git diff -w "$@" | view - }

alias glg='git lg'
compdef _git gpl=git-log
alias glgs='git log --stat --max-count=5'
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