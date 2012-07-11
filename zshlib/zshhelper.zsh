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

# Usage: simple-extract <file>
# Description: extracts archived files (maybe)
  function depack() {
    if [[ -f $1 ]]; then
      case $1 in
        *.tar.bz2)  bzip2 -v -d $1      ;;
        *.tar.gz)   tar -xvzf $1        ;;
        *.rar)      unrar $1            ;;
        *.deb)      ar -x $1            ;;
        *.bz2)      bzip2 -d $1         ;;
        *.lzh)      lha x $1            ;;
        *.gz)       gunzip -d $1        ;;
        *.tar)      tar -xvf $1         ;;
        *.tgz)      gunzip -d $1        ;;
        *.tbz2)     tar -jxvf $1        ;;
        *.zip)      unzip $1            ;;
        *.7z)       7z x $1             ;;
        *.Z)        uncompress $1       ;;
        *)          echo "'$1' Error. Please go away" ;;
      esac
    else
      echo "'$1' is not a valid file"
    fi
  }

# Usage: smartcompress <file> (<type>)
# Description: compresses files or a directory.  Defaults to tar.gz
function pack() {
	if [ $2 ]; then
	  case $2 in
	    tgz | tar.gz)   tar -zcvf$1.$2 $1 ;;
	    tbz2 | tar.bz2) tar -jcvf$1.$2 $1 ;;
	    tar.Z)          tar -Zcvf$1.$2 $1 ;;
	    tar)            tar -cvf$1.$2  $1 ;;
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
    BACKUPPATH="Dropbox/cfg-Desktop"
    echo "$fg_bold[red]Save all Login/ZSH Session Files:$fg_bold[white]"

    cp ~/.xinitrc ~/$BACKUPPATH/xinitrc
    echo "xinitrc"

    cp ~/.zshrc ~/$BACKUPPATH/zshrc
    echo "zshrc"

    cp ~/.zlogout ~/$BACKUPPATH/zlogout
    echo "zlogout"

    cp ~/.zprofile ~/$BACKUPPATH/zprofile
    echo "zprofile"

    cp ~/.zshbindings ~/$BACKUPPATH/zshbindings
    echo "zshbindings"

    cp ~/.dput.cf ~/$BACKUPPATH/dput.cf
    echo "ppa upload"

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