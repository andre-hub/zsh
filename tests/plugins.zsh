# Sourced by tests/run.zsh inside its isolated fixture and cleanup boundary.
check 'Plugins_RestoredInventory_ExpectedFilesPresent' clean "$zsh_bin" -d -f -c '
  for plugin in colored-man-pages fzf-completion fzf-key-bindings tmux vi-mode debian battery xfce git git-alias golang github archlinux cygwin ssh-agent gpg-agent sql; do
    [[ -f $TEST_ROOT/zshplugins/$plugin.plugin.zsh ]] || exit 1
  done
'
check 'Plugins_DefaultOff_NoRestoredDefinitions' clean "$zsh_bin" -d -f -i -c '
  source "$TEST_ROOT/zshrc"
  (( ! $+functions[fzf-file-widget] && ! $+functions[battery_pct] )) || exit 1
  (( ${#_zsh_loaded_plugins} == 0 ))
'
check 'Plugins_AllSelected_HeadlessCleanLoad' clean "$zsh_bin" -d -f -i -c '
  files=( "$TEST_ROOT"/zshplugins/*.plugin.zsh(N) )
  names=( "${files[@]:t}" )
  export ZSH_PUBLIC_PLUGINS=${(j.:.)names}
  source "$TEST_ROOT/zshrc" 2> "$TEST_WORK/plugin-errors"
  [[ ! -s $TEST_WORK/plugin-errors ]] || exit 1
  (( ${#_zsh_loaded_plugins} == ${#files} ))
'
check 'Plugins_MissingDependencies_SourceWithoutCommands' clean "$zsh_bin" -d -f -i -c '
  path=()
  for file in "$TEST_ROOT"/zshplugins/*.plugin.zsh(N); do
    source "$file" || exit 1
  done
'
print -r -- '(( ++PLUGIN_LOAD_COUNT )); return 0' > "$repo/zshplugins/count.plugin.zsh"
check 'Plugins_DuplicateSelectionAndResource_LoadOnce' clean "$zsh_bin" -d -f -i -c '
  typeset -gi PLUGIN_LOAD_COUNT=0
  export ZSH_PUBLIC_PLUGINS=count.plugin.zsh:count.plugin.zsh
  source "$TEST_ROOT/zshrc"
  source "$TEST_ROOT/zshrc"
  (( PLUGIN_LOAD_COUNT == 1 && ${#_zsh_loaded_plugins} == 1 ))
'
print -r -- '(( ++PLUGIN_RETRY_COUNT )); (( PLUGIN_RETRY_COUNT > 1 ))' > "$repo/zshplugins/retry.plugin.zsh"
check 'Plugins_FailedSource_RetryOnResource' clean "$zsh_bin" -d -f -i -c '
  typeset -gi PLUGIN_RETRY_COUNT=0
  export ZSH_PUBLIC_PLUGINS=retry.plugin.zsh
  source "$TEST_ROOT/zshrc" 2>/dev/null
  (( ${#_zsh_loaded_plugins} == 0 )) || exit 1
  source "$TEST_ROOT/zshrc"
  (( PLUGIN_RETRY_COUNT == 2 && ${#_zsh_loaded_plugins} == 1 ))
'
# Fzf is a presence-only stub here: loading may register widgets, never run it.
print -rl -- '#!/bin/sh' 'exit 99' > "$work/bin/fzf"
chmod +x "$work/bin/fzf"
check 'Plugins_FzfAndViBothOrders_PreserveWidgets' clean "$zsh_bin" -d -f -i -c '
  export TERM=xterm
  path=("$TEST_WORK/bin" $path)
  for order in "vi-mode fzf-completion fzf-key-bindings" "fzf-completion fzf-key-bindings vi-mode"; do
    bindkey -e
    bindkey -M viins "^R" history-incremental-search-backward
    for plugin in ${(z)order}; do
      source "$TEST_ROOT/zshplugins/$plugin.plugin.zsh" || exit 1
    done
    [[ $(bindkey -M viins "^R") == *fzf-history-widget ]] || exit 1
    [[ $(bindkey -M viins "^T") == *fzf-file-widget ]] || exit 1
    [[ $(bindkey -M viins "^I") == *fzf-completion ]] || exit 1
  done
'
check 'Plugins_NoninteractiveSelection_NoLoading' clean "$zsh_bin" -d -f -c '
  typeset -gi PLUGIN_LOAD_COUNT=0
  export ZSH_PUBLIC_PLUGINS=count.plugin.zsh
  source "$TEST_ROOT/zshrc"
  (( PLUGIN_LOAD_COUNT == 0 ))
'
# OS dispatch is simulated; this is not a native macOS/FreeBSD runtime test.
mkdir -p "$work/battery-bin"
print -rl -- '#!/bin/sh' '[ "$*" = "-b" ] || exit 99' \
  'printf "%s\n" "Battery 0: Discharging, 42%, 01:23:00 remaining"' > "$work/battery-bin/acpi"
print -rl -- '#!/bin/sh' '[ "$*" = "-g batt" ] || exit 99' \
  'printf "%s\n" "InternalBattery 42%; charging; 1:23 remaining"' > "$work/battery-bin/pmset"
print -rl -- '#!/bin/sh' '[ "$*" = "-i 0" ] || exit 99' \
  'printf "%s\n" "State: discharging" "Remaining capacity: 42%" "Remaining time: 1:23"' > "$work/battery-bin/acpiconf"
chmod +x "$work/battery-bin/"*
check 'Battery_PlatformStubs_ParseAndDispatch' clean "$zsh_bin" -d -f -c '
  source "$TEST_ROOT/zshplugins/battery.plugin.zsh"
  path=("$TEST_WORK/battery-bin")
  for system in linux-gnu darwin freebsd; do
    OSTYPE=$system
    [[ $(battery_pct) == 42 ]] || exit 1
    [[ $(battery_time_remaining) == (1:23|01:23:00) ]] || exit 1
    if [[ $system == darwin ]]; then
      battery_is_charging || exit 1
      [[ $(battery_pct_remaining) == "External Power" ]] || exit 1
    else
      battery_is_charging && exit 1
      [[ $(battery_pct_remaining) == 42 ]] || exit 1
    fi
  done
  OSTYPE=unknown
  battery_pct && exit 1
  path=()
  OSTYPE=linux-gnu
  battery_pct && exit 1
  [[ -z $(battery_pct_prompt) ]]
'
print -rl -- '#!/bin/sh' 'exit 99' > "$work/bin/thunar"
chmod +x "$work/bin/thunar"
check 'Desktop_HeadlessAndDisplay_ExplicitBrowseOnly' clean "$zsh_bin" -d -f -i -c '
  path=("$TEST_WORK/bin")
  source "$TEST_ROOT/zshplugins/xfce.plugin.zsh"
  (( ! $+aliases[browse] )) || exit 1
  DISPLAY=:test
  source "$TEST_ROOT/zshplugins/xfce.plugin.zsh"
  [[ $aliases[browse] == thunar ]]
'

check 'Plugins_Resource_PreserveFzfAndViBindings' clean "$zsh_bin" -d -f -i -c '
  export TERM=xterm
  path=("$TEST_WORK/bin" $path)
  export ZSH_PUBLIC_PLUGINS=vi-mode.plugin.zsh:fzf-completion.plugin.zsh:fzf-key-bindings.plugin.zsh
  source "$TEST_ROOT/zshrc"
  source "$TEST_ROOT/zshrc"
  [[ $(bindkey -M viins "^R") == *fzf-history-widget ]] || exit 1
  [[ $(bindkey -M viins "^T") == *fzf-file-widget ]] || exit 1
  [[ $(bindkey -M viins "^I") == *fzf-completion ]]
'
mkdir -p "$work/dev-bin"
print -rl -- '#!/bin/sh' \
  '[ "$#" = 7 ] && [ "$1" = -X ] && [ "$2" = -P ] && [ "$3" = linestyle=unicode ] && [ "$4" = -P ] && [ "$5" = null=NULL ] && [ "$6" = -f ] && [ "$7" = "query with spaces.sql" ] || exit 99' \
  'exit 37' > "$work/dev-bin/psql"
print -rl -- '#!/bin/sh' \
  '[ "$*" = "symbolic-ref --quiet --short HEAD" ] || exit 99' \
  'printf "%s\n" "feature%test"' > "$work/dev-bin/git"
chmod +x "$work/dev-bin/"*
check 'DevHelpers_ArgumentsStatusAndPrompt_EscapedPreserved' clean "$zsh_bin" -d -f -c '
  path=("$TEST_WORK/dev-bin")
  source "$TEST_ROOT/zshplugins/sql.plugin.zsh"
  source "$TEST_ROOT/zshplugins/git.plugin.zsh"
  sql -f "query with spaces.sql"; result=$?
  (( result == 37 )) || exit 1
  [[ $(git_super_status) == "(feature%%test)" ]]
'
check 'AuthHelpers_LoadAndInvalidInput_NoMutation' clean "$zsh_bin" -d -f -c '
  export SSH_AUTH_SOCK=fixture-socket GPG_TTY=fixture-terminal
  source "$TEST_ROOT/zshplugins/ssh-agent.plugin.zsh"
  source "$TEST_ROOT/zshplugins/gpg-agent.plugin.zsh"
  [[ $SSH_AUTH_SOCK == fixture-socket && $GPG_TTY == fixture-terminal ]] || exit 1
  ssh_agent_use /nonexistent 2>/dev/null; result=$?
  (( result == 2 )) || exit 1
  gpg_tty_refresh </dev/null; result=$?
  (( result == 1 )) || exit 1
  [[ $SSH_AUTH_SOCK == fixture-socket && $GPG_TTY == fixture-terminal ]]
'
# Model a producer terminated by SIGPIPE after fzf accepts an early selection.
mkdir -p "$work/sigpipe-bin" "$work/fzf paths/chosen path"
print -rl -- '#!/bin/sh' 'printf "%s\0" "${FIND_TEST_ITEM:-./chosen path}"' 'exit "${FIND_TEST_STATUS:-141}"' > "$work/sigpipe-bin/find"
print -rl -- '#!/bin/sh' '/bin/cat' 'exit "${FZF_TEST_STATUS:-0}"' > "$work/sigpipe-bin/fzf"
chmod +x "$work/sigpipe-bin/"*
check 'Fzf_ProducerSigpipe_AcceptSelectionButRespectCancellation' clean "$zsh_bin" -d -f -i -c '
  export TERM=xterm
  path=("$TEST_WORK/sigpipe-bin" $path)
  source "$TEST_ROOT/zshplugins/fzf-completion.plugin.zsh"
  source "$TEST_ROOT/zshplugins/fzf-key-bindings.plugin.zsh"
  zle() { return 0; }
  cd "$TEST_WORK/fzf paths"
  setopt pipefail
  LBUFFER="cat "
  fzf-file-widget
  [[ $LBUFFER == "cat ./chosen\\ path " && -o pipefail ]] || exit 1
  LBUFFER="cat **"
  fzf-completion
  [[ $LBUFFER == "cat ./chosen\\ path " ]] || exit 1
  fzf-cd-widget
  [[ $PWD == "$TEST_WORK/fzf paths/chosen path" ]] || exit 1
  export FZF_TEST_STATUS=130
  LBUFFER="unchanged "
  fzf-file-widget
  [[ $LBUFFER == "unchanged " ]] || exit 1
  LBUFFER="cat **"
  fzf-completion
  [[ $LBUFFER == "cat **" ]] || exit 1
  before=$PWD
  fzf-cd-widget
  [[ $PWD == $before && -o pipefail ]] || exit 1
  export FZF_TEST_STATUS=0 FIND_TEST_STATUS=2
  LBUFFER="unchanged "
  fzf-file-widget
  [[ $LBUFFER == "unchanged " ]] || exit 1
  export FIND_TEST_STATUS=141
  FIND_TEST_ITEM="./line
break;\$(false)"
  export FIND_TEST_ITEM
  LBUFFER="cat "
  fzf-file-widget
  [[ $LBUFFER == "cat ${(q)FIND_TEST_ITEM} " ]] || exit 1
  LBUFFER="cat **"
  fzf-completion
  [[ $LBUFFER == "cat ${(q)FIND_TEST_ITEM} " ]]
'
