# Some useful keybindings
#
#  bindkey "^Y"    yank                                # <STRG>-Y
#  bindkey "\e[3~" delete-char                         # Delete
#  bindkey '^[[7~' beginning-of-line                   # Home (xterm)
#  bindkey '^[[8~'  end-of-line                        # End (xterm)
#  bindkey '^[[5~'  history-beginning-search-backward  # Page Up
#  bindkey '^[[6~'  history-beginning-search-forward   # Page Down
#  bindkey '^[[2~' overwrite-mode                      # Insert
#  bindkey "^[[A"  up-line-or-search                   # <ESC>-N
#  bindkey "^[[B"  down-line-or-search                 # <ESC>-
#  bindkey "^Q"  edit-command-line                     # <STRG>-Q
#  bindkey " "     magic-space                         # ' ' (Space>
#  bindkey "^B"    backward-word                       # <STRG>-B
#  bindkey "^E"    expand-cmd-path                     # <STRG>-E
#  bindkey "^N"    forward-word                        # <STRG>-N
#  bindkey "^R"    history-incremental-search-backward # <STRG>-R
#  bindkey "^P"    quote-line                          # <STRG>-P
#  bindkey "^K"    run-help                            # <STRG>-K
#  bindkey "^Z"    which-command                       # <STRG>-Z
#  bindkey "^X"    what-cursor-position                # <STRG>-X

# TODO: Explain what some of this does..
bindkey -e
bindkey '\ew' kill-region
bindkey -s '\el' "ls\n"
bindkey -s '\e.' "..\n"
bindkey '^r' history-incremental-search-backward
bindkey "^[[5~" up-line-or-history
bindkey "^[[6~" down-line-or-history

# make search up and down work, so partially type and hit up/down to find relevant stuff
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

bindkey "^[[H" beginning-of-line
bindkey "^[[1~" beginning-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[4~" end-of-line
bindkey "^[OF" end-of-line
bindkey ' ' magic-space    # also do history expansion on space

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

bindkey '^[[Z' reverse-menu-complete

# Make the delete key (or Fn + Delete on the Mac) work instead of outputting a ~
bindkey '^?' backward-delete-char
bindkey "^[[3~" delete-char
bindkey "^[3;5~" delete-char
bindkey "\e[3~" delete-char

# consider emacs keybindings:

#bindkey -e  ## emacs key bindings
#
#bindkey '^[[A' up-line-or-search
#bindkey '^[[B' down-line-or-search
#bindkey '^[^[[C' emacs-forward-word
#bindkey '^[^[[D' emacs-backward-word
#
#bindkey -s '^X^Z' '%-^M'
#bindkey '^[e' expand-cmd-path
#bindkey '^[^I' reverse-menu-complete
#bindkey '^X^N' accept-and-infer-next-history
#bindkey '^W' kill-region
#bindkey '^I' complete-word
## Fix weird sequence that rxvt produces
#bindkey -s '^[[Z' '\t'
#

case $TERM in
xterm*)
# Pos1 && End
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
;;
#screen*)
#bindkey "^[OH" beginning-of-line
#bindkey "^[OF" end-of-line
#;;
screen*)
bindkey "^[[1~"  beginning-of-line
bindkey "^[[4~"  end-of-line
;;
linux*)
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
;;
rxvt*)
bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line
;;
Eterm*)
bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line
;;
esac

bindkey "^[[2~" yank			# Einfg
bindkey "^[[5~" up-line-or-history	# PageUp
bindkey "^[[6~" down-line-or-history	# PageDown
bindkey "^[e" expand-cmd-path		# C-e for expanding path of typed command
bindkey "^[[A" up-line-or-search	# up arrow for back-history-search
bindkey "^[[B" down-line-or-search	# down arrow for fwd-history-search
bindkey " " magic-space			# do history expansion on space
bindkey "\e[3~" delete-char		# "Entf" or "Del"
bindkey "^[[A" history-search-backward	# PgUp
bindkey "[B" history-search-forward	# PgDown
bindkey "[C" forward-char		# ->
bindkey "[D" backward-char		# <-
bindkey "q" push-line			# Kill the *complete* line! (ESC+q)
bindkey ":5D" history-incremental-search-backward # Search in my $HISTFILE (STRG+R)
bindkey ';5A' history-beginning-search-backward   # 
bindkey ';5B' history-beginning-search-forward    #
#bindkey "[[5~"  history-beginning-search-backward-end
#bindkey "[[6~"  history-beginning-search-forward-end
bindkey "^[[2;5~" insert-last-word	# STRG+Einfg
bindkey '^[[2' insert-last-word 	# STRG+Einfg
bindkey "a" accept-and-hold		# ESC+a
bindkey "^B"  backward-word		# One word back
bindkey "^X"  forward-word		# One word forward
bindkey "^P" quote-line			# quote the whole line
bindkey -s "\C-t" "dirs -v\rcd ~"	# STRG+t
bindkey "^I" expand-or-complete		# assimilable to "ls<TAB>"
bindkey "^E" expand-cmd-path		# $ ls<STRG+E> == /bin/ls

run-with-sudo () { LBUFFER="sudo $LBUFFER" }
zle -N run-with-sudo
bindkey "^K" run-with-sudo


# Help Output of Bindings
zshbindings() {
  echo "$fg_bold[grey]" && uname -s -r && date +"%x  %R"
  echo "$fg_bold[blue]# yank                                      $fg_bold[red]# <STRG>-Y"
  echo "$fg_bold[blue]# delete-char                               $fg_bold[red]# Delete"
  echo "$fg_bold[blue]# beginning-of-line                         $fg_bold[red]# Home (xterm)"
  echo "$fg_bold[blue]# end-of-line                               $fg_bold[red]# End (xterm)"
  echo "$fg_bold[blue]# history-beginning-search-backward         $fg_bold[red]# Page Up"
  echo "$fg_bold[blue]# history-beginning-search-forward          $fg_bold[red]# Page Down"
  echo "$fg_bold[blue]# overwrite-mode                            $fg_bold[red]# Insert"
  echo "$fg_bold[blue]# up-line-or-search                         $fg_bold[red]# <ESC>-N"
  echo "$fg_bold[blue]# down-line-or-search                       $fg_bold[red]# <ESC>-"
  echo "$fg_bold[blue]# edit-command-line                         $fg_bold[red]# <STRG>-Q"    
  echo "$fg_bold[blue]# backward-word                             $fg_bold[red]# <STRG>-B"
  echo "$fg_bold[blue]# expand-cmd-path                           $fg_bold[red]# <STRG>-E"
  echo "$fg_bold[blue]# forward-word                              $fg_bold[red]# <STRG>-N"
  echo "$fg_bold[blue]# history-incremental-search-backward       $fg_bold[red]# <STRG>-R"
  echo "$fg_bold[blue]# quote-line                                $fg_bold[red]# <STRG>-P"
  echo "$fg_bold[blue]# run-with-sudo                             $fg_bold[red]# <STRG>-K"
  echo "$fg_bold[blue]# which-command                             $fg_bold[red]# <STRG>-Z"
  echo "$fg_bold[blue]# what-cursor-position                      $fg_bold[red]# <STRG>-X"
  }