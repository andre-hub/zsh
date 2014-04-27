###########         CLI Helpers        ###########
 function helper() {
   echo "$fg_bold[blue]Helper Tools for Shell Users$fg_bold[white]"
   echo "# pack() & depack()"
   echo "# zshbackup()"
   echo "# homeclean()"
   echo "# backup() & srv-backup()"
   echo "# packagelist() & packageinstall()"
   echo "# apt-date() & ins()"
   echo "# dl()"
   echo "# info: sudo sysctl vm.swappiness=0"
   }

function openurl {
  URL=$1

  CNTFF=`findBrowser "firefox"`
  CNTCH=`findBrowser "chromium"`

  echo "$*" > $HOME/logurls

  if [ $CNTFF -ge 1 ] 
  then
      /usr/bin/firefox "$URL"
  elif [ $CNTCH -ge 1 ] 
  then
      /usr/bin/chromium "$URL"
  else
      echo "No running browser instance"
  fi
}

function findBrowser {
    processName=$1
    ps ax | grep "$processName" | grep -v grep | wc -l
}

# Usage: simple-extract <file>
# Description: extracts archived files (maybe)
  function depack() {
	if [[ -f "$1" ]]; then
		case "$1" in
			*.tar.lrz)
				b=$(basename "$1" .tar.lrz)
				lrztar -d "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.lrz)
				b=$(basename "$1" .lrz)
				lrunzip "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.tar.bz2)
				b=$(basename "$1" .tar.bz2)
				tar xjf "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.bz2)
				b=$(basename "$1" .bz2)
				bunzip2 "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.tar.gz)
				b=$(basename "$1" .tar.gz)
				tar xzf "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.gz)
				b=$(basename "$1" .gz)
				gunzip "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.tar.xz)
				b=$(basename "$1" .tar.xz)
				tar Jxf "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.xz)
				b=$(basename "$1" .gz)
				xz -d "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.rar)
				b=$(basename "$1" .rar)
				unrar e "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.tar)
				b=$(basename "$1" .tar)
				tar xf "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.tbz2)
				b=$(basename "$1" .tbz2)
				tar xjf "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.tgz)
				b=$(basename "$1" .tgz)
				tar xzf "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.zip)
				b=$(basename "$1" .zip)
				unzip "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.Z)
				b=$(basename "$1" .Z)
				uncompress "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*.7z)
				b=$(basename "$1" .7z)
				7z x "$1" && [[ -d "$b" ]] && cd "$b" ;;
			*) echo "don't know how to extract '$1'..." && return 1;;
		esac
		return 0
	else
		echo "'$1' is not a valid file!"
		return 1
	fi
  }

# Usage: smartcompress <file> (<type>)
# Description: compresses files or a directory.  Defaults to tar.gz
function pack() {
	if [ $2 ]; then
	  case $2 in
	    tgz | tar.gz)   tar -zcvf $1.$2 $1 ;;
	    tbz2 | tar.bz2) tar -jcvf $1.$2 $1 ;;
	    tar.Z)          tar -Zcvf $1.$2 $1 ;;
	    tar)            tar -cvf $1.$2  $1 ;;
	    gz | gzip)      gzip           $1 ;;
	    bz2 | bzip2)    bzip2          $1 ;;
	    7z |7zip)   7z a $1.$2     $1 ;;
	    *)
	    echo "Error: $2 is not a valid compression type"
	    ;;
	  esac
	else
	  pack $1 tar.gz
	fi
}

# gui alternative bleachbit
function homeclean() {
	echo "cleaning home dir"
	echo " - thumbnails"
	/bin/rm -f ~/.local/share/grisbi/*
	/bin/rm -f ~/.thumbnails/fail/thunar-vfs/*
	/bin/rm -f ~/.thumbnails/normal/*
	echo " - firefox"
	/bin/rm -f ~/.mozilla/firefox/*/adblockplus/*backup*
	/bin/rm -f ~/.mozilla/firefox/*/bookmarkbackups/*
	for f in ~/.mozilla/firefox/*/*.sqlite; do sqlite3 $f 'VACUUM;'; done
	#echo " - sessions"
	#/bin/rm -f ~/.cache/sessions/*
	echo " - chromium"
	sqlite3 ~/.config/chromium/Safe\ Browsing\ Bloom 'VACUUM;'
	sqlite3 ~/.config/chromium/Default/Archived\ History 'VACUUM;'
	sqlite3 ~/.config/chromium/Default/Cookies 'VACUUM;'
	sqlite3 ~/.config/chromium/Default/Extension\ Cookies 'VACUUM;'
	sqlite3 ~/.config/chromium/Default/History 'VACUUM;'
	sqlite3 ~/.config/chromium/Default/Thumbnails 'VACUUM;'
	sqlite3 ~/.config/chromium/Default/Web\ Data 'VACUUM;'
	for f in ~/.config/chromium/Default/Local\ Storage/*localstorage; do sqlite3 $f 'VACUUM;'; done
	for f in ~/.config/chromium/Default/databases/*; do sqlite3 $f 'VACUUM;'; done
	echo " - penguintv"
	#/bin/rm -rf ~/.penguintv/media/*
	for f in ~/.penguintv/*.db; do sqlite3 $f 'VACUUM;'; done
	#echo " - liferea"
	#for f in ~/.liferea_*/*.db; do sqlite3 $f 'VACUUM;'; done
	#echo " - Miro"
	#sqlite3 ~/.miro/sqlitedb 'VACUUM;'
	#/bin/rm -rf ~/.miro/*log*
	echo "create compdump"
	compdump
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

# Usage: srv-backup ()
# Description: backup server data  Defaults /var/www
  function srv-backup() {
    Y=`date +%Y-%m`
    P="~/Data/Backups/srv"
    srv_www_p="/var/www/"
    # - - - - -
    A=`pwd`
    TP="/tmp/srv-backup"
    echo "$fg_bold[blue]"
    mkdir $TP
    cd $TP
    7z a "$TP/srv-backup-$Y.7z" $srv_www_p/*
    mysqldump --user=root --password= --all-databases > srv-mysql-$Y.sql
    7z a "$TP/srv-backup-$Y.7z" $TP/srv-mysql-$Y.sql
    tar -cf "$P/srv-backup-$Y.tar" "srv-backup-$Y.7z"
    cd $A
    rm -r $TP
  }


# Usage: srv-full-backup ()
# Description: backup server data  Defaults /var/www
  function srv-full-backup() {
    Y=`date +%Y-%m-%d_%H.%M`
    P="~/Archiv"
    srv_p="/data/srv/"
    srv_www_p="www/"
    srv_mysql_p="mysql/"
    # - - - - -
    A=pwd
    TP="/tmp/srv-backup"
    echo "$fg_bold[blue]"
    mkdir $TP
    cd $srv_p
    tar -cpf "$TP/srv-mysql-backup-$Y.tar" "$srv_mysql_p"
    tar -cpf "$TP/srv-www-backup-$Y.tar" "$srv_www_p"
    7z a "$P/srv-backup-$Y.7z" "$TP/srv-*"
    cd $A
    rm -r $TP
  }

# shutdown pc
  function off () {
     sudo poweroff
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


# Escape potential tarbombs
# http://www.commandlinefu.com/commands/view/6824/escape-potential-tarbombs
etb() {
  l=$(tar tf $1);
  if [ $(echo "$l" | wc -l) -eq $(echo "$l" | grep $(echo "$l" | head -n1) | wc -l) ];
  then tar xf $1;
  else mkdir ${1%.t(ar.gz||ar.bz2||gz||bz||ar)} && tar xvf $1 -C ${1%.t(ar.gz||ar.bz2||gz||bz||ar)};
  fi ;
}

# show newest files
# http://www.commandlinefu.com/commands/view/9015/find-the-most-recently-changed-files-recursively
newest () {find . -type f -printf '%TY-%Tm-%Td %TT %p\n' | grep -v cache | grep -v ".hg" | grep -v ".git" | sort -r | less }

# http://www.commandlinefu.com/commands/view/7294/backup-a-file-with-a-date-time-stamp
buf () {
    oldname=$1;
    if [ "$oldname" != "" ]; then
        datepart=$(date +%Y-%m-%d);
        firstpart=`echo $oldname | cut -d "." -f 1`;
        newname=`echo $oldname | sed s/$firstpart/$firstpart.$datepart/`;
        cp -R ${oldname} ${newname};
    fi
}

function printHookFunctions () {
    print -C 1 ":::pwd_functions:" $chpwd_functions
    print -C 1 ":::periodic_functions:" $periodic_functions
    print -C 1 ":::precmd_functions:" $precmd_functions
    print -C 1 ":::preexec_functions:" $preexec_functions
    print -C 1 ":::zshaddhistory_functions:" $zshaddhistory_functions
    print -C 1 ":::zshexit_functions:" $zshexit_functions
}

# Rename files in a directory in an edited list fashion
# http://www.commandlinefu.com/commands/view/7818/
function massmove () {
    ls > ls; paste ls ls > ren; vi ren; sed 's/^/mv /' ren|bash; rm ren ls
}


# Put a console clock in top right corner
# http://www.commandlinefu.com/commands/view/7916/
function clock () {
    while sleep 1;
    do
        tput sc
        tput cup 0 $(($(tput cols)-29))
        date
        tput rc
    done &
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

# translate via google language tools (more lightweight than leo)
# http://www.commandlinefu.com/commands/view/5034/
translate() {
    wget -qO- "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=$1&langpair=$2|${3:-en}" | sed 's/.*"translatedText":"\([^"]*\)".*}/\1\n/'
}


function gitCleanPull() {
    git stash clear
    git clean -f -f *
    git checkout master --force
    git pull --rebase
}

function rDir() {
    for d ($1/*(/)) {
        echo $d
        cd $d && $2 && cd ..
    } 
}

function zsh_stats() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head
}

function take() {
  mkdir -p $1
  cd $1
}