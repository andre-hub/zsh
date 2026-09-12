# Helpers are opt-in commands, never executed during startup.
findProcess() {
  (( $# == 1 )) || { print -u2 'usage: findProcess <pattern>'; return 2; }
  command pgrep -fl -- "$1"
}

open_command() {
  emulate -L zsh
  (( $# )) || { print -u2 'usage: open_command <file-or-url> [...]'; return 2; }
  case $OSTYPE in
    darwin*) command open "$@" ;;
    linux*|freebsd*)
      (( $+commands[xdg-open] )) || { print -u2 'open_command: xdg-open is not installed'; return 127; }
      command xdg-open "$@" ;;
    *) print -u2 'open_command: unsupported platform'; return 1 ;;
  esac
}

urlencode() {
  (( $# == 1 )) || { print -u2 'usage: urlencode <text>'; return 2; }
  command python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"
}
urldecode() {
  (( $# == 1 )) || { print -u2 'usage: urldecode <text>'; return 2; }
  command python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote_plus(sys.argv[1]))' "$1"
}

dl() (
  emulate -L zsh
  (( $# >= 1 && $# <= 2 )) || { print -u2 'usage: dl <url> [destination-directory]'; return 2; }
  (( $+commands[aria2c] )) || { print -u2 'dl: aria2c is not installed'; return 127; }
  builtin cd -- "${2:-$PWD}" 2>/dev/null || { print -u2 'dl: destination unavailable'; return 1; }
  command aria2c -c -j 8 -x 12 --quiet=true -- "$1" 2>/dev/null || { print -u2 'dl: download failed'; return 1; }
)

# Run an explicit command in each immediate child directory, preserving cwd.
rDir() (
  emulate -L zsh
  (( $# >= 2 )) && [[ -d $1 ]] || { print -u2 'usage: rDir <directory> <command> [argument ...]'; return 2; }
  local root=${1:a} directory result=0
  shift
  for directory in "$root"/*(/N); do
    (builtin cd -- "$directory" && "$@") || result=$?
  done
  return $result
)

# Stage next to the output; os.link publishes without replacing a racing target.
_zsh_pdfwrite() (
  emulate -L zsh
  local output=${1:a} staging
  shift
  (( $+commands[gs] && $+commands[python3] )) || { print -u2 'PDF: Ghostscript and Python 3 are required'; return 127; }
  [[ ! -e $output && ! -L $output ]] || { print -u2 'PDF: output already exists'; return 1; }
  staging=$(command mktemp -d "${output:h}/.zsh-pdf.XXXXXXXX" 2>/dev/null) || { print -u2 'PDF: output directory unavailable'; return 1; }
  trap 'command rm -rf -- "$staging"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  command gs -q -dBATCH -dNOPAUSE -dSAFER -sDEVICE=pdfwrite "-sOutputFile=$staging/output.pdf" "$@" >/dev/null 2>&1 || { print -u2 'PDF: conversion failed'; return 1; }
  [[ -s $staging/output.pdf ]] || { print -u2 'PDF: empty output'; return 1; }
  command python3 -c 'import os,sys; os.link(sys.argv[1], sys.argv[2])' "$staging/output.pdf" "$output" 2>/dev/null || { print -u2 'PDF: output publication failed'; return 1; }
)

pdfmerge() {
  emulate -L zsh
  (( $# >= 2 )) || { print -u2 'usage: pdfmerge <first.pdf> <second.pdf> [...]'; return 2; }
  local output="${1%.*}-new.pdf" file
  local -a inputs=()
  for file in "$@"; do
    [[ -f $file ]] || { print -u2 'pdfmerge: missing input'; return 1; }
    inputs+=("${file:a}")
  done
  _zsh_pdfwrite "$output" -dPDFSETTINGS=/prepress "${inputs[@]}"
}

pdfresize() {
  emulate -L zsh
  (( $# >= 2 && $# <= 3 )) && [[ -f $1 ]] || { print -u2 'usage: pdfresize <input.pdf> <output.pdf> [dpi]'; return 2; }
  local dpi=${3:-150}
  [[ $dpi == <1-9600> ]] || { print -u2 'pdfresize: dpi must be between 1 and 9600'; return 2; }
  _zsh_pdfwrite "$2" -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
    -dEmbedAllFonts=true -dSubsetFonts=true -dAutoRotatePages=/None \
    -dColorImageDownsampleType=/Bicubic -dColorImageResolution=$dpi \
    -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution=$dpi \
    -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution=$dpi "${1:a}"
}

# Optional user TSV; an explicitly loaded provider may add entries.
typeset -g _zsh_bookmark_file=${ZSH_BOOKMARK_FILE:-$HOME/.config/zsh/bookmarks.tsv}

_zsh_bookmark_read() {
  emulate -L zsh
  local line category description command_text
  [[ -r $1 ]] || { print -u2 'bookmark: favorites file is missing'; return 1; }
  while IFS= read -r line || [[ -n $line ]]; do
    [[ -z $line || $line == \#* ]] && continue
    [[ $line == *$'\t'*$'\t'* ]] || { print -u2 'bookmark: invalid favorites record'; return 1; }
    category=${line%%$'\t'*}
    line=${line#*$'\t'}
    description=${line%%$'\t'*}
    command_text=${line#*$'\t'}
    [[ -n $category && -n $description && -n $command_text && $command_text != *$'\t'* ]] || {
      print -u2 'bookmark: invalid favorites record'; return 1
    }
    entries+=("$command_text")
    rows+=("${#entries}"$'\t'"$category"$'\t'"$description"$'\t'"$command_text")
  done < "$1"
}

_zsh_bookmark_select() {
  emulate -L zsh
  (( $# <= 1 )) && [[ ${1:-} == (''|--legacy|--all) ]] || {
    print -u2 'usage: bookmark [--legacy|--all]'; return 2
  }
  (( $+commands[fzf] )) || { print -u2 'bookmark: fzf is not installed'; return 127; }
  local mode=${1:-} line category description command_text selected number color rest
  local -a entries=() rows=() display_rows=() palette=(36 34 33 32 35 37)
  local -A category_colors=()
  if [[ $mode != --legacy ]]; then
    if [[ -r $_zsh_bookmark_file ]]; then
      _zsh_bookmark_read "$_zsh_bookmark_file" || return $?
    fi
    if (( $+functions[_zsh_bookmark_extra] )); then
      _zsh_bookmark_extra || return $?
    fi
  fi
  if [[ $mode == --legacy || $mode == --all ]]; then
    if [[ -r $HOME/.zsh_bookmarks ]]; then
      while IFS= read -r line || [[ -n $line ]]; do
        [[ -n $line ]] || continue
        entries+=("$line")
        rows+=("${#entries}"$'\tLegacy\tBookmark\t'"$line")
      done < "$HOME/.zsh_bookmarks"
    elif [[ $mode == --legacy ]]; then
      print -u2 'bookmark: legacy bookmark file is missing'; return 1
    fi
  fi
  (( ${#entries} )) || { print -u2 'bookmark: no entries'; return 1; }
  # Color only the display category, never the command or authoritative rows.
  for line in "${rows[@]}"; do
    number=${line%%$'\t'*}
    rest=${line#*$'\t'}
    category=${rest%%$'\t'*}
    rest=${rest#*$'\t'}
    if [[ -z ${category_colors[$category]:-} ]]; then
      color=$palette[$(( ${#category_colors} % ${#palette} + 1 ))]
      category_colors[$category]=$color
    fi
    color=$category_colors[$category]
    display_rows+=("$number"$'\t\e[1;'"${color}m${category}"$'\e[0m\t'"$rest")
  done
  # No inherited execute/preview bindings; commands are opaque data, never eval.
  selected=$(FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE=/dev/null command fzf \
    --ansi --no-multi --delimiter=$'\t' --with-nth=2.. --height=60% --reverse \
    --color='prompt:cyan,pointer:magenta,marker:green,hl:yellow,hl+:yellow,header:blue,info:cyan' \
    --prompt='Bookmarks > ' --header='Search · Enter: edit · Esc: cancel' \
    <<< "${(F)display_rows}") || return $?
  number=${selected%%$'\t'*}
  [[ $number == <1-> ]] && (( number <= ${#entries} )) || return 1
  # fzf --ansi strips presentation escapes; accept only the exact known row
  # (or its exact colored representation), then return the separate raw entry.
  [[ $selected == "$rows[number]" || $selected == "$display_rows[number]" ]] || return 1
  REPLY=$entries[number]
}

bookmark() {
  emulate -L zsh
  local REPLY
  _zsh_bookmark_select "$@" || return $?
  print -rz -- "$REPLY"
}

bookmark-widget() {
  emulate -L zsh
  local REPLY
  if _zsh_bookmark_select; then
    BUFFER=$REPLY
    CURSOR=${#BUFFER}
  fi
  zle redisplay
}

if [[ -o interactive ]]; then
  zle -N bookmark-widget
  bindkey -M emacs '\eb' bookmark-widget
  bindkey -M viins '\eb' bookmark-widget
fi

chmodx() {
  emulate -L zsh
  (( $# )) && [[ -f $1 ]] || { print -u2 'usage: chmodx <file> [argument ...]'; return 2; }
  local executable=${1:a}
  shift
  command chmod +x -- "$executable" 2>/dev/null || { print -u2 'chmodx: chmod failed'; return 1; }
  "$executable" "$@"
}

shebang() {
  emulate -L zsh
  setopt extended_glob noclobber
  (( $# == 2 )) && [[ $1 == [a-zA-Z][a-zA-Z0-9._+-]# ]] || { print -u2 'usage: shebang <interpreter-name> <new-file>'; return 2; }
  local interpreter=$1 target=${2:a}
  local -a editor=("${(@Q)${(z)${VISUAL:-${EDITOR:-vim}}}}")
  [[ ! -e $target && ! -L $target ]] || { print -u2 'shebang: target already exists'; return 1; }
  (( $+commands[$interpreter] )) || { print -u2 'shebang: interpreter is not installed'; return 127; }
  if [[ $editor[1] == */* ]]; then
    [[ -f $editor[1] && -x $editor[1] ]] || { print -u2 'shebang: editor is not executable'; return 127; }
  else
    (( ${#editor} )) && (( $+commands[$editor[1]] )) || { print -u2 'shebang: editor is not installed'; return 127; }
  fi
  { print -r -- "#!/usr/bin/env $interpreter" > "$target"; } 2>/dev/null || { print -u2 'shebang: cannot create target'; return 1; }
  command chmod +x -- "$target" 2>/dev/null || { print -u2 'shebang: chmod failed'; return 1; }
  "${editor[@]}" "$target"
}

zshbindings() { bindkey; }

yt() {
  (( $# == 1 )) || { print -u2 'usage: yt <url>'; return 2; }
  (( $+commands[yt-dlp] )) || { print -u2 'yt: yt-dlp is not installed'; return 127; }
  command yt-dlp --quiet --no-progress --no-overwrites -x -- "$1" 2>/dev/null || { print -u2 'yt: download failed'; return 1; }
}

# Only generic hardware properties; no hostname, addresses or serial numbers.
hardwareinfo() {
  emulate -L zsh
  local cpu memory
  case $OSTYPE in
    linux*|cygwin*)
      cpu=$(command awk -F ': *' '/model name|^Processor/{print $2; exit}' /proc/cpuinfo 2>/dev/null) || return 1
      memory=$(command awk '/MemTotal:/{printf "%.1f", $2/1048576}' /proc/meminfo 2>/dev/null) || return 1
      ;;
    freebsd*|darwin*)
      if [[ $OSTYPE == freebsd* ]]; then
        cpu=$(command sysctl -n hw.model 2>/dev/null) || return 1
        memory=$(command sysctl -n hw.physmem 2>/dev/null) || return 1
      else
        cpu=$(command sysctl -n machdep.cpu.brand_string 2>/dev/null) || cpu=$(command sysctl -n hw.model 2>/dev/null) || return 1
        memory=$(command sysctl -n hw.memsize 2>/dev/null) || return 1
      fi
      [[ $memory == <-> ]] || return 1
      memory=$(print -r -- "$memory" | command awk '{printf "%.1f", $1/1073741824}')
      ;;
    *) print -u2 'hardwareinfo: unsupported platform'; return 1 ;;
  esac
  [[ -n $cpu && -n $memory ]] || { print -u2 'hardwareinfo: properties unavailable'; return 1; }
  print -rl -- "CPU: $cpu" "RAM: $memory GiB"
}
