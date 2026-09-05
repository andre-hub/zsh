#!/usr/bin/env zsh
# Preview by default; never overwrite files, directories or other symlinks.
emulate -LR zsh
setopt err_exit no_unset
root=${0:A:h}
apply=0
with_tmux=0
for arg in "$@"; do
  case "$arg" in
    --apply) apply=1 ;;
    --tmux) with_tmux=1 ;;
    --help|-h) print 'Usage: ./create-links.sh [--apply] [--tmux]'; exit 0 ;;
    *) print -u2 'Unknown option; use --help.'; exit 2 ;;
  esac
done
[[ -n ${HOME:-} && -d $HOME ]] || { print -u2 'HOME must be an existing directory.'; exit 1; }
zdotdir=${ZDOTDIR:-$HOME}
[[ -d $zdotdir ]] || { print -u2 'ZDOTDIR must be an existing directory.'; exit 1; }
if (( apply )) && (( ! $+commands[python3] )); then
  print -u2 "Installation requires Python 3 for safe link creation."
  exit 1
fi
sources=(zshrc zprofile zlogout)
targets=("$zdotdir/.zshrc" "$zdotdir/.zprofile" "$zdotdir/.zlogout")
if (( with_tmux )); then
  sources+=(tmux.conf)
  targets+=("$HOME/.tmux.conf")
fi
# Check every target before changing anything, including dangling links.
for (( i=1; i<=${#sources}; i++ )); do
  src=$root/$sources[i]
  dst=$targets[i]
  [[ -f $src ]] || { print -u2 'Required repository file is missing.'; exit 1; }
  if [[ -L $dst && ${dst:A} == ${src:A} ]]; then
    continue
  elif [[ -e $dst || -L $dst ]]; then
    print -u2 'Installation refused: an existing startup file or link would be replaced. Back it up manually first.'
    exit 1
  fi
done
for (( i=1; i<=${#sources}; i++ )); do
  src=$root/$sources[i]
  dst=$targets[i]
  [[ -L $dst && ${dst:A} == ${src:A} ]] && continue
  if (( apply )); then
    # An exact symlink syscall never follows a concurrently created directory.
    command python3 - "$src" "$dst" <<'PYLINK'
import os
import sys
try:
    os.symlink(sys.argv[1], sys.argv[2])
except OSError:
    print("Installation refused: startup link could not be created safely.", file=sys.stderr)
    sys.exit(1)
PYLINK
  fi
done
if (( apply )); then
  print 'Configuration linked. Start a new zsh to use it.'
else
  print 'Preview OK: startup links can be created. Run with --apply to install; --tmux also links the optional tmux configuration.'
fi
