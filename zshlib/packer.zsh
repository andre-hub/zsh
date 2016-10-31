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
      *.xz)
        b=$(basename "$1" .xz)
        xz -k -v -d "$1" && [[ -d "$b" ]] && cd "$b" ;; 
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
      7z |7zip)       7z a $1.$2     $1 ;;
      xz)             xz -k -v -z $1 ;;
      *)
      echo "Error: $2 is not a valid compression type"
      ;;
    esac
  else
    pack $1 tar.gz
  fi
}