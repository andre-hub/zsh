# Extract only trusted archives into a suitable working directory.
# Extraction tools determine overwrite and path handling; this is not a sandbox.
depack() {
  emulate -L zsh
  setopt pipefail
  (( $# == 1 )) && [[ -f $1 ]] || { print -u2 'usage: depack <archive>'; return 2; }
  local file=${1:a} base=${1:t}
  case $file in
    *.tar.gz|*.tgz) command tar -xzf "$file" ;;
    *.tar.bz2|*.tbz2) command tar -xjf "$file" ;;
    *.tar.xz) command tar -xJf "$file" ;;
    *.tar.zst) command zstd -dc -- "$file" | command tar -xf - ;;
    *.tar) command tar -xf "$file" ;;
    *.gz) command gunzip -- "$file" ;;
    *.bz2) command bunzip2 -- "$file" ;;
    *.xz) command xz -d -- "$file" ;;
    *.zst) command zstd -d -- "$file" ;;
    *.zip) command unzip "$file" ;;
    *.7z) command 7z x "$file" ;;
    *.rar) command unrar x "$file" ;;
    *.Z) command uncompress "$file" ;;
    *) print -u2 'depack: unsupported archive type'; return 2 ;;
  esac
  local result=$?
  (( result == 0 )) || return $result
  case $base in
    *.tar.*) base=${base%.tar.*} ;;
    *) base=${base%.*} ;;
  esac
  [[ ! -d $base ]] || builtin cd -- "$base" || return
  return 0
}

pack() {
  emulate -L zsh
  setopt pipefail
  (( $# >= 1 && $# <= 2 )) && [[ -e $1 ]] || { print -u2 'usage: pack <path> [type]'; return 2; }
  local name=${1%/} type=${2:-tar.gz}
  [[ $name == /* ]] || name=./$name
  case $type in
    tgz|tar.gz) command tar -zcf "${name}.${type}" "$name" ;;
    tbz2|tar.bz2) command tar -jcf "${name}.${type}" "$name" ;;
    tar.xz) command tar -Jcf "${name}.tar.xz" "$name" ;;
    tar.zst) command tar -cf - "$name" | command zstd -o "${name}.tar.zst" ;;
    tar) command tar -cf "${name}.tar" "$name" ;;
    gz|gzip) command gzip -- "$name" ;;
    bz2|bzip2) command bzip2 -- "$name" ;;
    xz) command xz -k -- "$name" ;;
    zst|zstd) command zstd -- "$name" ;;
    7z|7zip) command 7z a "${name}.7z" "$name" ;;
    *) print -u2 'pack: unsupported compression type'; return 2 ;;
  esac
}

packFolder() {
  emulate -L zsh
  (( $# == 1 )) && [[ -d $1 ]] || { print -u2 'usage: packFolder <directory>'; return 2; }
  local name=${1%/} destination
  [[ $name == /* ]] || name=./$name
  destination="${name}-$(date +%Y-%m-%d_%H-%M).tar.xz"
  [[ ! -e $destination ]] || { print -u2 'packFolder: destination already exists'; return 1; }
  # One archive operation; failures never trigger rename/removal of unrelated files.
  command tar -Jcf "$destination" "$name"
}
