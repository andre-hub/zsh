#!/usr/bin/env zsh
emulate -LR zsh
setopt no_unset
root=${0:A:h:h}
integer failed=0
for suite in run git-navigation helpers media repo terminfo-guard; do
  command zsh -d -f "$root/tests/$suite.zsh" || failed=1
done
exit $failed
