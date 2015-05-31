# Setup hub function for git, if it is available; http://github.com/defunkt/hub
if [ "$commands[(I)hub]" ] && [ "$commands[(I)ruby]" ]; then
    # Autoload _git completion functions
    if declare -f _git > /dev/null; then
      _git
    fi
    
    if declare -f _git_commands > /dev/null; then
        _hub_commands=(
            'alias:show shell instructions for wrapping git'
            'pull-request:open a pull request on GitHub'
            'fork:fork origin repo on GitHub'
            'create:create new repo on GitHub for the current project'
            'browse:browse the project on GitHub'
            'compare:open GitHub compare view'
        )
        # Extend the '_git_commands' function with hub commands
        eval "$(declare -f _git_commands | sed -e 's/base_commands=(/base_commands=(${_hub_commands} /')"
    fi
    # eval `hub alias -s zsh`
    function git(){
        if ! (( $+_has_working_hub  )); then
            hub --version &> /dev/null
            _has_working_hub=$(($? == 0))
        fi
        if (( $_has_working_hub )) ; then
            hub "$@"
        else
            command git "$@"
        fi
    }
fi

# Functions #################################################################
# empty_gh [NAME_OF_REPO]
#
# Use this when creating a new repo from scratch.
empty_gh() { # [NAME_OF_REPO]
    repo=$1
    url=githubUrl $repo
    mkdir "$repo"
    cd "$repo"
 
    gitNewRepository
    touch README
    git add README
    git commit -m 'Initial commit.'
    git remote add origin $url
    git push -u origin master
}

# new_gh [DIRECTORY]
#
# Use this when you have a directory that is not yet set up for git.
# This function will add all non-hidden files to git.
new_gh() { # [DIRECTORY]
    cd "$1"
    url=`githubUrl $1`
 
    gitNewRepository
    git add *
    git commit -m 'Initial commit.'

    githubApiAdd $1
    git remote add origin $url
    git push -u origin master
}

# exist_gh [DIRECTORY]
#
# Use this when you have a git repo that's ready to go and you want to add it
# to your GitHub.
exist_gh() { # [DIRECTORY]
    cd "$1"
    url=`githubUrl $1`
    
    githubApiAdd $1
    git remote add origin $url
    git push -u origin master
}

# gitNewRepository 
#
# create a new git repo without filemode
gitNewRepository() {
    git init    
    git config core.filemode false
}

# githubUrl [repositoryName]
#
# get your github url for a repo
githubUrl() {
    repo=$1
    ghuser="$(  git config github.user )"
    url="https://github.com/${ghuser}/$repo.git"
    echo $url
}

# addIgnoreFile
#
# create a new gitignore file
addIgnoreFile() {
    # add all non-dot files
    print '.*'"\n"'*~' > .gitignore
}


# githubApiAdd [repositoryName]
#
# create a new repository on github
githubApiAdd() {
    ghuser="$(  git config github.user )"
    data='{ "name": "'${1}'", "private": false }'
    curl -u ${ghuser} --data "${data}" https://api.github.com/user/repos 
}

# git.io "GitHub URL"
#
# Shorten GitHub url, example:
#   https://github.com/nvogel/dotzsh    >   http://git.io/8nU25w  
# source: https://github.com/nvogel/dotzsh
# documentation: https://github.com/blog/985-git-io-github-url-shortener
#
git.io() {curl -i -s http://git.io -F "url=$1" | grep "Location" | cut -f 2 -d " "}

# End Functions #############################################################