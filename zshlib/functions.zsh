function findProcess {
    processName=$1
    ps ax | grep "$processName" | grep -v grep
  }

function open_command() {
  emulate -L zsh
  setopt shwordsplit

  local open_cmd

  # define the open command
  case "$OSTYPE" in
    darwin*)  open_cmd='open' ;;
    cygwin*)  open_cmd='cygstart' ;;
    linux*)   open_cmd='xdg-open' ;;
    msys*)    open_cmd='start ""' ;;
    *)        echo "Platform $OSTYPE not supported"
              return 1
              ;;
  esac

  # don't use nohup on OSX
  if [[ "$OSTYPE" == darwin* ]]; then
    $open_cmd "$@" &>/dev/null
  else
    nohup $open_cmd "$@" &>/dev/null
  fi
}

# Get the value of an alias.
#
# Arguments:
#    1. alias - The alias to get its value from
# STDOUT:
#    The value of alias $1 (if it has one).
# Return value:
#    0 if the alias was found,
#    1 if it does not exist
#
function alias_value() {
    alias "$1" | sed "s/^$1='\(.*\)'$/\1/"
    test $(alias "$1")
}


# URL-encode a string
#
# Encodes a string using RFC 2396 URL-encoding (%-escaped).
# See: https://www.ietf.org/rfc/rfc2396.txt
#
# By default, reserved characters and unreserved "mark" characters are
# not escaped by this function. This allows the common usage of passing
# an entire URL in, and encoding just special characters in it, with
# the expectation that reserved and mark characters are used appropriately.
# The -r and -m options turn on escaping of the reserved and mark characters,
# respectively, which allows arbitrary strings to be fully escaped for
# embedding inside URLs, where reserved characters might be misinterpreted.
#
# Prints the encoded string on stdout.
# Returns nonzero if encoding failed.
#
# Usage:
#  omz_urlencode [-r] [-m] [-P] <string>
#
#    -r causes reserved characters (;/?:@&=+$,) to be escaped
#
#    -m causes "mark" characters (_.!~*''()-) to be escaped
#
#    -P causes spaces to be encoded as '%20' instead of '+'
function omz_urlencode() {
  emulate -L zsh
  zparseopts -D -E -a opts r m P

  local in_str=$1
  local url_str=""
  local spaces_as_plus
  if [[ -z $opts[(r)-P] ]]; then spaces_as_plus=1; fi
  local str="$in_str"

  # URLs must use UTF-8 encoding; convert str to UTF-8 if required
  local encoding=$langinfo[CODESET]
  local safe_encodings
  safe_encodings=(UTF-8 utf8 US-ASCII)
  if [[ -z ${safe_encodings[(r)$encoding]} ]]; then
    str=$(echo -E "$str" | iconv -f $encoding -t UTF-8)
    if [[ $? != 0 ]]; then
      echo "Error converting string from $encoding to UTF-8" >&2
      return 1
    fi
  fi

  # Use LC_CTYPE=C to process text byte-by-byte
  local i byte ord LC_ALL=C
  export LC_ALL
  local reserved=';/?:@&=+$,'
  local mark='_.!~*''()-'
  local dont_escape="[A-Za-z0-9"
  if [[ -z $opts[(r)-r] ]]; then
    dont_escape+=$reserved
  fi
  # $mark must be last because of the "-"
  if [[ -z $opts[(r)-m] ]]; then
    dont_escape+=$mark
  fi
  dont_escape+="]"

  # Implemented to use a single printf call and avoid subshells in the loop,
  # for performance (primarily on Windows).
  local url_str=""
  for (( i = 1; i <= ${#str}; ++i )); do
    byte="$str[i]"
    if [[ "$byte" =~ "$dont_escape" ]]; then
      url_str+="$byte"
    else
      if [[ "$byte" == " " && -n $spaces_as_plus ]]; then
        url_str+="+"
      else
        ord=$(( [##16] #byte ))
        url_str+="%$ord"
      fi
    fi
  done
  echo -E "$url_str"
}

# URL-decode a string
#
# Decodes a RFC 2396 URL-encoded (%-escaped) string.
# This decodes the '+' and '%' escapes in the input string, and leaves
# other characters unchanged. Does not enforce that the input is a
# valid URL-encoded string. This is a convenience to allow callers to
# pass in a full URL or similar strings and decode them for human
# presentation.
#
# Outputs the encoded string on stdout.
# Returns nonzero if encoding failed.
#
# Usage:
#   omz_urldecode <urlstring>  - prints decoded string followed by a newline
function omz_urldecode {
  emulate -L zsh
  local encoded_url=$1

  # Work bytewise, since URLs escape UTF-8 octets
  local caller_encoding=$langinfo[CODESET]
  local LC_ALL=C
  export LC_ALL

  # Change + back to ' '
  local tmp=${encoded_url:gs/+/ /}
  # Protect other escapes to pass through the printf unchanged
  tmp=${tmp:gs/\\/\\\\/}
  # Handle %-escapes by turning them into `\xXX` printf escapes
  tmp=${tmp:gs/%/\\x/}
  local decoded
  eval "decoded=\$'$tmp'"

  # Now we have a UTF-8 encoded string in the variable. We need to re-encode
  # it if caller is in a non-UTF-8 locale.
  local safe_encodings
  safe_encodings=(UTF-8 utf8 US-ASCII)
  if [[ -z ${safe_encodings[(r)$caller_encoding]} ]]; then
    decoded=$(echo -E "$decoded" | iconv -f UTF-8 -t $caller_encoding)
    if [[ $? != 0 ]]; then
      echo "Error converting string from UTF-8 to $caller_encoding" >&2
      return 1
    fi
  fi

  echo -E "$decoded"
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
     aria2c -c -j 2 -x 10 $1
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
  gs -dBATCH -dNOPAUSE -o ${1/'.pdf'/'-new.pdf'} -sDevice=pdfwrite -dPDFSETTING=/prepress $1 $2 $3
}

function pdfreconvert() {
  gs -r600 -o ${1/'.pdf'/'-new.pdf'} -sDevice=pdfwrite -dPDFSETTING=/prepress $1
}

function dotFolderBackup {
  name=$1
  mv .$name $name
  pack $name tar
  mv $name .$name
  pack $name.tar xz
  mv $name.tar.xz $name-`date +%Y-%m-%d_%H-%M`.tar.xz
  rm $name.tar
}