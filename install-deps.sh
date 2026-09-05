#!/bin/sh
# Guidance only: no downloads, privilege escalation or package changes.
set -eu
case "${1:-}" in
  ''|--help|-h) ;;
  *) printf '%s\n' 'Usage: ./install-deps.sh (prints commands only)' >&2; exit 2 ;;
esac
[ "$#" -le 1 ] || { printf '%s\n' 'Usage: ./install-deps.sh (prints commands only)' >&2; exit 2; }
printf '%s\n' 'Run the appropriate command manually if these tools are wanted:'
case "$(uname -s)" in
  Linux)
    printf '%s\n' \
      'Debian/Ubuntu: sudo apt-get install zsh python3 git tmux unzip zip xz-utils bzip2' \
      'Arch Linux: sudo pacman -S zsh python git tmux unzip zip xz bzip2' ;;
  FreeBSD) printf '%s\n' 'FreeBSD: sudo pkg install zsh python3 git tmux unzip zip' ;;
  Darwin) printf '%s\n' 'macOS (Homebrew already installed): brew install zsh python git tmux' ;;
  CYGWIN*) printf '%s\n' 'Cygwin: select zsh, python3, git, tmux, unzip and zip in the Cygwin setup program.' ;;
  *) printf '%s\n' 'Install zsh and Python 3 with your system package manager; git, tmux and archive tools are optional.' ;;
esac
printf '%s\n' \
  'Optional media: FFmpeg (including ffprobe and the selected encoders), ImageMagick 7 (magick).' \
  'Optional helpers: aria2 (dl), Ghostscript + Python 3 (PDF), yt-dlp (yt), fzf (bookmark/widgets).' \
  'Optional forge lists: GitHub CLI (gh) or Gitea CLI (tea) plus jq; configure authentication separately.' \
  'Package names and codec support vary by platform; nothing is installed by this script.'
