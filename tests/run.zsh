#!/usr/bin/env zsh
# Run with: zsh -d -f tests/run.zsh. No user startup or Git configuration is read.
emulate -LR zsh
setopt err_exit no_unset pipe_fail
root=${0:A:h:h}
zsh_bin=${commands[zsh]}
work=$(mktemp -d "$root/tests/.run.XXXXXXXX")
trap '/bin/rm -rf -- "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
# Keep ownership in the outer shell: fatal expansion errors can bypass zsh EXIT traps.
(
mkdir -p "$work/home with spaces" "$work/tmp" "$work/repo with spaces" "$work/bin"
repo="$work/repo with spaces"
cp "$root"/{zshrc,zprofile,zlogout,create-links.sh,install-deps.sh,tmux.conf} "$repo/"
cp -R "$root/zshlib" "$repo/"
cp -R "$root/zshplugins" "$repo/"
home="$work/home with spaces"
export TEST_ROOT="$repo" TEST_WORK="$work"
# env -i excludes inherited startup, loader, locale and Git configuration knobs.
clean() {
  command env -i HOME="$home" ZDOTDIR="$home" TMPDIR="$work/tmp" \
    PATH=/usr/bin:/bin:/usr/sbin:/sbin LANG=C LC_ALL=C TERM=dumb \
    GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null \
    TEST_ROOT="$repo" TEST_WORK="$work" "$@"
}
integer passed=0 failed=0
check() {
  local label=$1
  shift
  if "$@" >"$work/output" 2>&1; then
    print -r -- "ok - $label"
    (( ++passed ))
  else
    # Do not copy command output or environment values into test reports.
    print -r -- "not ok - $label"
    (( ++failed ))
  fi
}
syntax() {
  local file
  for file in "$root"/{zshrc,zprofile,zlogout,create-links.sh} "$root"/zshlib/*.zsh "$root"/zshplugins/*.zsh(N) "$root"/tests/*.zsh; do
    "$zsh_bin" -d -f -n "$file" || return
  done
  /bin/sh -n "$root/install-deps.sh"
}
check 'Syntax_AllShellFiles_Parse' syntax
check 'Startup_Noninteractive_NoModulesOrWrites' clean "$zsh_bin" -d -f -c '
  before=$PATH
  source "$TEST_ROOT/zshrc"
  source "$TEST_ROOT/zlogout"
  [[ $PATH == $before && $LANG == C && $LC_ALL == C ]] || exit 1
  (( ! $+functions[pack] )) || exit 1
  files=( "$HOME"/*(ND) )
  (( ${#files} == 0 ))
'
mkdir -p "$home/.zshlib"
print -r -- 'print touched > "$HOME/legacy-marker"' > "$home/.zshlib/legacy.zsh"
print -r -- 'print touched > "$HOME/unlisted-marker"' > "$repo/zshlib/unlisted.zsh"
check 'Startup_Interactive_AllowlistAndEnvironment' clean "$zsh_bin" -d -f -i -c '
  initial=("$path[@]")
  source "$TEST_ROOT/zprofile"
  source "$TEST_ROOT/zshrc"
  [[ $LANG == C && $LC_ALL == C && ! -e $HOME/legacy-marker && ! -e $HOME/unlisted-marker ]] || exit 1
  [[ "${(j.:.)path[1,${#initial}]}" == "${(j.:.)initial}" ]] || exit 1
  (( $+functions[pack] && $+functions[mcd] && $+functions[git_current_branch] ))
'
print -r -- 'typeset -g SELECTED_PLUGIN=loaded' > "$repo/zshplugins/local.plugin.zsh"
print -r -- 'print touched > "$HOME/outside-marker"' > "$work/outside.zsh"
ln -s "$work/outside.zsh" "$repo/zshplugins/escape.zsh"
check 'Startup_ModulesDisabled_ExplicitOptOut' clean "$zsh_bin" -d -f -i -c '
  export ZSH_PUBLIC_DISABLE_MODULES=git.zsh:packer.zsh
  source "$TEST_ROOT/zshrc"
  (( ! $+functions[pack] && ! $+functions[git_current_branch] && $+functions[mcd] ))
'
check 'Startup_Plugins_DefaultOffSelectedOnly' clean "$zsh_bin" -d -f -i -c '
  source "$TEST_ROOT/zshrc"
  (( ! $+SELECTED_PLUGIN )) || exit 1
  export ZSH_PUBLIC_PLUGINS=local.plugin.zsh
  source "$TEST_ROOT/zshrc"
  [[ $SELECTED_PLUGIN == loaded ]]
'
check 'Startup_Plugins_RejectTraversalAndSymlinkEscape' clean "$zsh_bin" -d -f -i -c '
  export ZSH_PUBLIC_PLUGINS=escape.zsh:../../outside.zsh
  source "$TEST_ROOT/zshrc"
  [[ ! -e $HOME/outside-marker ]]
'
check 'Startup_NewModules_ExplicitlyLoadedOnce' clean "$zsh_bin" -d -f -i -c '
  source "$TEST_ROOT/zshrc"
  (( $+functions[imgresize] && $+functions[repo-open] && $+functions[spectrum_ls] )) || exit 1
  functions[imgresize]="return 37"
  functions[repo-open]="return 38"
  functions[spectrum_ls]="return 39"
  saved=( "$functions[imgresize]" "$functions[repo-open]" "$functions[spectrum_ls]" )
  source "$TEST_ROOT/zshrc"
  [[ $functions[imgresize] == "$saved[1]" && $functions[repo-open] == "$saved[2]" && $functions[spectrum_ls] == "$saved[3]" ]]
'
check 'Startup_NewModules_DisabledWithoutThemeDependency' clean "$zsh_bin" -d -f -i -c '
  export ZSH_PUBLIC_DISABLE_MODULES=media.zsh:repo.zsh:theme-and-appearance.zsh
  source "$TEST_ROOT/zshrc"
  (( ! $+functions[imgresize] && ! $+functions[repo-open] && $+functions[spectrum_ls] )) || exit 1
  spectrum_ls >/dev/null || exit
  spectrum_bls >/dev/null
'
check 'Startup_SpectrumDisabled_ExplicitOptOut' clean "$zsh_bin" -d -f -i -c '
  export ZSH_PUBLIC_DISABLE_MODULES=spectrum.zsh
  source "$TEST_ROOT/zshrc"
  (( ! $+functions[spectrum_ls] && ! $+functions[spectrum_bls] ))
'
check 'Completion_Default_Initialized' clean "$zsh_bin" -d -f -i -c '
  source "$TEST_ROOT/zshrc"
  (( $+functions[compdef] && $+functions[_main_complete] ))
'
check 'Completion_Disabled_NotInitialized' clean "$zsh_bin" -d -f -i -c '
  export ZSH_PUBLIC_DISABLE_MODULES=completion.zsh
  source "$TEST_ROOT/zshrc"
  (( ! $+functions[compdef] && ! $+functions[_main_complete] ))
'
check 'Startup_CoreModuleSymlink_RejectOutsideFile' clean "$zsh_bin" -d -f -i -c '
  fixture="$TEST_WORK/symlink module"
  mkdir -p "$fixture/zshlib"
  cp "$TEST_ROOT/zshrc" "$fixture/zshrc"
  ln -s "$TEST_WORK/outside.zsh" "$fixture/zshlib/functions.zsh"
  source "$fixture/zshrc"
  [[ ! -e $HOME/outside-marker ]]
'
check 'Startup_CoreDirectorySymlink_RejectOutsideTree' clean "$zsh_bin" -d -f -i -c '
  fixture="$TEST_WORK/symlink directory"
  mkdir -p "$fixture" "$TEST_WORK/outside modules"
  cp "$TEST_ROOT/zshrc" "$fixture/zshrc"
  cp "$TEST_WORK/outside.zsh" "$TEST_WORK/outside modules/functions.zsh"
  ln -s "$TEST_WORK/outside modules" "$fixture/zshlib"
  source "$fixture/zshrc"
  [[ ! -e $HOME/outside-marker ]]
'
check 'Installer_Preview_NoLinks' clean "$zsh_bin" -d -f -c '
  "$commands[zsh]" -d -f "$TEST_ROOT/create-links.sh" || exit
  [[ ! -e $HOME/.zshrc && ! -L $HOME/.zshrc && ! -e $HOME/.tmux.conf ]]
'
check 'Installer_ApplySpaces_Idempotent' clean "$zsh_bin" -d -f -c '
  for attempt in 1 2; do
    "$commands[zsh]" -d -f "$TEST_ROOT/create-links.sh" --apply --tmux || exit
  done
  for file in zshrc zprofile zlogout; do
    target=$HOME/.$file
    [[ -L $target && ${target:A} == $TEST_ROOT/$file ]] || exit 1
  done
  [[ -L $HOME/.tmux.conf ]] || exit 1
'
check 'Startup_InstalledSymlink_ResolvesRepository' clean "$zsh_bin" -d -f -i -c '
  source "$HOME/.zshrc"
  [[ $ZSH_PUBLIC_ROOT == $TEST_ROOT ]] && (( $+functions[pack] ))
'
check 'Installer_Conflicts_NoPartialInstall' clean "$zsh_bin" -d -f -c '
  export ZDOTDIR="$TEST_WORK/conflict"
  mkdir "$ZDOTDIR"
  print -r -- preserved > "$ZDOTDIR/.zlogout"
  "$commands[zsh]" -d -f "$TEST_ROOT/create-links.sh" --apply && exit 1
  [[ $(<"$ZDOTDIR/.zlogout") == preserved && ! -e $ZDOTDIR/.zshrc && ! -L $ZDOTDIR/.zshrc ]] || exit 1
  rm "$ZDOTDIR/.zlogout"
  ln -s "$ZDOTDIR/missing" "$ZDOTDIR/.zprofile"
  "$commands[zsh]" -d -f "$TEST_ROOT/create-links.sh" --apply && exit 1
  [[ -L $ZDOTDIR/.zprofile && ! -e $ZDOTDIR/.zshrc && ! -L $ZDOTDIR/.zshrc ]]
'
check 'Installer_TargetDirectoryRace_NoNestedLink' clean "$zsh_bin" -d -f -c '
  export ZDOTDIR="$TEST_WORK/race-home"
  mkdir -p "$ZDOTDIR" "$TEST_WORK/race-bin"
  real_python=$commands[python3]
  print -rl -- "#!/bin/sh" "mkdir -- \"\$3\" || exit 98" \
    "exec ${(q)real_python} \"\$@\"" > "$TEST_WORK/race-bin/python3"
  chmod +x "$TEST_WORK/race-bin/python3"
  path=("$TEST_WORK/race-bin" $path)
  "$commands[zsh]" -d -f "$TEST_ROOT/create-links.sh" --apply && exit 1
  [[ -d $ZDOTDIR/.zshrc && ! -L $ZDOTDIR/.zshrc ]] || exit 1
  children=( "$ZDOTDIR/.zshrc"/*(ND) )
  (( ${#children} == 0 )) || exit 1
  [[ ! -e $ZDOTDIR/.zprofile && ! -L $ZDOTDIR/.zprofile ]]
'
check 'Archives_FailedCommands_PreserveFailureAndDirectory' clean "$zsh_bin" -d -f -c '
  source "$TEST_ROOT/zshlib/packer.zsh"
  mkdir -p "$TEST_WORK/archive case/folder" "$TEST_WORK/failing-bin"
  cd "$TEST_WORK/archive case"
  print data > sample.tar
  print "#!/bin/sh\nexit 37" > "$TEST_WORK/failing-bin/tar"
  chmod +x "$TEST_WORK/failing-bin/tar"
  path=("$TEST_WORK/failing-bin" $path)
  initial=$PWD
  pack folder tar; result=$?
  (( result == 37 )) || exit 1
  depack sample.tar; result=$?
  (( result == 37 )) || exit 1
  packFolder folder; result=$?
  (( result == 37 )) && [[ $PWD == $initial ]]
'
check 'Archives_RealTar_RoundTripWithSpaces' clean "$zsh_bin" -d -f -c '
  source "$TEST_ROOT/zshlib/packer.zsh"
  mkdir -p "$TEST_WORK/round trip/source folder"
  cd "$TEST_WORK/round trip"
  print data > "source folder/file name"
  pack "source folder" tar || exit
  mkdir extract
  cd extract
  depack "../source folder.tar" || exit
  [[ $(<"file name") == data ]]
'
check 'Directories_Mcd_SpacesAndFailure' clean "$zsh_bin" -d -f -c '
  source "$TEST_ROOT/zshlib/directories.zsh"
  mcd "$TEST_WORK/new directory" || exit
  [[ $PWD == "$TEST_WORK/new directory" ]] || exit 1
  initial=$PWD
  print data > existing
  mcd existing/child && exit 1
  [[ $PWD == $initial ]]
'
check 'Helpers_RDir_ArgumentsFailureAndCwd' clean "$zsh_bin" -d -f -c '
  source "$TEST_ROOT/zshlib/functions.zsh"
  mkdir -p "$TEST_WORK/children/one child" "$TEST_WORK/children/second"
  initial=$PWD
  rDir "$TEST_WORK/children" /bin/sh -c '\''printf "%s" "$1" > marker'\'' sh "two words" || exit
  [[ $(<"$TEST_WORK/children/one child/marker") == "two words" ]] || exit 1
  [[ $(<"$TEST_WORK/children/second/marker") == "two words" ]] || exit 1
  rDir "$TEST_WORK/children" /bin/sh -c "exit 29"; result=$?
  (( result == 29 )) && [[ $PWD == $initial ]]
'
# These are dispatch tests with uname stubs, not native tests of other systems.
check 'Dependencies_PlatformStubs_GuidanceOnly' clean "$zsh_bin" -d -f -c '
  mkdir -p "$TEST_WORK/platform-bin"
  print "#!/bin/sh\nprintf '\''%s\\n'\'' \"\$TEST_SYSTEM\"" > "$TEST_WORK/platform-bin/uname"
  chmod +x "$TEST_WORK/platform-bin/uname"
  for tool in sudo apt-get pacman pkg brew; do
    print "#!/bin/sh\nexit 99" > "$TEST_WORK/platform-bin/$tool"
    chmod +x "$TEST_WORK/platform-bin/$tool"
  done
  export PATH="$TEST_WORK/platform-bin:$PATH"
  for system in Linux FreeBSD Darwin CYGWIN_NT Unknown; do
    output=$(TEST_SYSTEM=$system /bin/sh "$TEST_ROOT/install-deps.sh") || exit
    case $system in
      Linux) [[ $output == *apt-get* && $output == *pacman* ]] || exit 1 ;;
      FreeBSD) [[ $output == *pkg\ install* ]] || exit 1 ;;
      Darwin) [[ $output == *brew\ install* ]] || exit 1 ;;
      CYGWIN_NT) [[ $output == *Cygwin\ setup* ]] || exit 1 ;;
      Unknown) [[ $output == *system\ package\ manager* ]] || exit 1 ;;
    esac
  done
'
source "$root/tests/plugins.zsh"
print -r -- "$passed passed; $failed failed"
(( failed == 0 ))
)
