function findProcess {
    processName=$1
    ps ax | grep "$processName" | grep -v grep
  }

  # simple backup of all files
  # (on future/todo: copy files to git repo dir and commit and upload to git hub)
  function zshbackup() {
    BACKUPPATH="workspace/zsh.git"
    echo "$fg_bold[red]Save all Login/ZSH Session Files:$fg_bold[white]"

    cp ~/.zshrc ~/$BACKUPPATH/zshrc
    echo "zshrc"

    cp ~/.zlogout ~/$BACKUPPATH/zlogout
    echo "zlogout"

    cp ~/.zprofile ~/$BACKUPPATH/zprofile
    echo "zprofile"

    if [ ! -d ~/$BACKUPPATH/zshlib ]; then
    mkdir ~/$BACKUPPATH/zshlib
    fi
    cp -R ~/.zshlib/* ~/$BACKUPPATH/zshlib/
    echo "zshlib"

    if [ ! -d ~/$BACKUPPATH/zshplugins ]; then
    mkdir ~/$BACKUPPATH/zshplugins
    fi
    cp -R ~/.zshplugins/* ~/$BACKUPPATH/zshplugins/
    echo "zshplugins"

    if [ ! -d ~/$BACKUPPATH/zsh-syntax-highlighting ]; then
    mkdir ~/$BACKUPPATH/zsh-syntax-highlighting
    fi
    cp -R ~/.zsh-syntax-highlighting/* ~/$BACKUPPATH/zsh-syntax-highlighting/
    echo "zsh-syntax-highlighting"
    }

# Usage: gpg-add ()
# Description: backup server data  Defaults /var/www
 function gpg-add(){
   if [ $1 ]; then
   gpg --keyserver keyserver.ubuntu.com --recv $1
   gpg --export --armor $1 | sudo apt-key add -
    else
      echo "gpg key not found"
    fi
  }

  function rsync-dotfiles() {
    if [ $1 ]; then
       rsync --copy-links ~/.* $1  2> ~/rsync-dotfiles.log
    else
      echo "target dir is require"
    fi
  }

 function dl() {
   if [ $1 ]; then
     temp=`pwd`
     if [ $2 ]; then
        cd $2
     else
        cd ~/Downloads/Temp/
     fi
     aria2c $1 $3
     cd $temp
  else
    echo "no url"
  fi
  }

# create a new script, automatically populating the shebang line, editing the
# script, and making it executable.
# http://www.commandlinefu.com/commands/view/8050/
shebang() {
    if i=$(which $1);
    then
        printf '#!/usr/bin/env %s\n\n' $1 > $2 && chmod 755 $2 && vim + $2 && chmod 755 $2;
    else
        echo "'which' could not find $1, is it in your \$PATH?";
    fi;
    # in case the new script is in path, this throw out the command hash table and
    # start over  (man zshbuiltins)
    rehash
}


function rDir() {
    for d ($1/*(/)) {
        echo $d
        cd $d && $2 && cd ..
    } 
}

function zshstats() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head
}

function take() {
  mkdir -p $1
  cd $1
}

function pdfmerge() {
  gs -o ${1/'.pdf'/'-new.pdf'} -sDevice=pdfwrite -dPDFSETTING=/prepress $1 $2 $3
}

function pdfreconvert() {
  gs -o ${1/'.pdf'/'-new.pdf'} -sDevice=pdfwrite -dPDFSETTING=/prepress $1
}