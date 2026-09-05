#!/usr/bin/env zsh
emulate -LR zsh
setopt err_exit no_unset pipe_fail
root=${0:A:h:h}
work=$(mktemp -d "$root/tests/.helpers.XXXXXXXX")
trap '/bin/rm -rf -- "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
(
  export HOME="$work/home" ZDOTDIR="$work/home" TRACE="$work/trace"
  mkdir -p "$HOME" "$work/bin" "$work/files"
  path=("$work/bin" /usr/bin /bin)
  cd "$work/files"
  source "$root/zshlib/functions.zsh"
  integer passed=0 failed=0 skipped=0
  check() {
    local label=$1; shift
    if ( "$@" ) > "$work/result" 2>&1; then
      print "ok - $label"; (( ++passed ))
    else
      local result=$?
      if (( result == 77 )); then print "skip - $label (dependency unavailable)"; (( ++skipped ))
      else print "not ok - $label"; (( ++failed )); fi
    fi
  }
  stub() { print -rl -- '#!/bin/sh' "$2" > "$work/bin/$1"; /bin/chmod +x "$work/bin/$1"; rehash; }
  chmod_arguments() {
    print -rl -- '#!/bin/sh' 'printf "%s\n" "$@" > "$TRACE"' > 'run file'
    chmodx 'run file' 'two words' ';touch forbidden' || return
    [[ $(<"$TRACE") == $'two words\n;touch forbidden' && ! -e forbidden ]]
  }
  chmod_failure() {
    stub chmod 'exit 9'
    print -rl -- '#!/bin/sh' 'touch forbidden' > failed
    chmodx failed && return 1
    [[ ! -e forbidden ]]
  }
  shebang_protected() {
    print preserved > existing
    shebang zsh existing && return 1
    [[ $(<existing) == preserved ]] || return
    ln -s missing dangling
    shebang zsh dangling && return 1
    [[ -L dangling && ! -e missing ]]
  }
  shebang_editor() {
    /bin/rm -f "$work/bin/chmod"
    stub editor 'printf "%s\n" "$@" > "$TRACE"'
    export VISUAL='editor --literal "two words"'
    shebang zsh 'new script' || return
    [[ $(<'new script') == '#!/usr/bin/env zsh' && -x 'new script' ]] || return
    local -a args=("${(@f)$(<"$TRACE")}")
    [[ $args[1] == --literal && $args[2] == 'two words' && $args[3] == "$PWD/new script" ]]
  }
  shebang_editor_paths() {
    stub 'editor space' 'printf "%s\n" "$@" > "$TRACE"'
    local executable="$work/bin/editor space"
    export VISUAL="${(qq)executable} --literal 'two words'"
    shebang zsh 'absolute editor script' || return
    local -a args=("${(@f)$(<"$TRACE")}")
    [[ $args[1] == --literal && $args[2] == 'two words' && $args[3] == "$PWD/absolute editor script" ]] || return
    cp "$executable" './relative editor'
    export VISUAL="'./relative editor' 'relative argument'"
    shebang zsh 'relative editor script' || return
    args=("${(@f)$(<"$TRACE")}")
    [[ $args[1] == 'relative argument' && $args[2] == "$PWD/relative editor script" ]] || return
    /bin/chmod -x './relative editor'
    shebang zsh 'nonexec editor script' && return 1
    [[ ! -e 'nonexec editor script' ]]
  }
  pdf_directory_failure_private() {
    local output
    output=$(pdfresize a.pdf 'synthetic-sensitive-marker/missing/output.pdf' 2>&1) && return 1
    [[ $output == 'PDF: output directory unavailable' && $output != *synthetic-sensitive-marker* ]]
  }
  shebang_invalid() { shebang 'zsh;touch forbidden' invalid && return 1; [[ ! -e invalid && ! -e forbidden ]]; }
  bookmark_edit_only() {
    stub fzf 'cat'
    print -r -- 'touch forbidden' > "$HOME/.zsh_bookmarks"
    local captured=''
    print() { if [[ $1 == -z ]]; then captured=$3; else builtin print "$@"; fi }
    bookmark || return
    [[ $captured == 'touch forbidden' && ! -e forbidden ]]
  }
  pdf_cases() {
    stub gs 'for arg do case "$arg" in -sOutputFile=*) out=${arg#*=};; esac; done; printf pdf > "$out"; exit "${GS_FAILURE:-0}"'
    print input > a.pdf; print input > 'b file.pdf'
    pdfmerge a.pdf 'b file.pdf' || return
    [[ $(<a-new.pdf) == pdf ]] || return
    pdfmerge a.pdf 'b file.pdf' && return 1
    ln -s absent.pdf link.pdf
    pdfresize a.pdf link.pdf && return 1
    [[ ! -e absent.pdf && -L link.pdf ]] || return
    GS_FAILURE=1 pdfresize a.pdf failed.pdf && return 1
    [[ ! -e failed.pdf ]] || return
    pdfresize a.pdf bad.pdf 0 && return 1
    local -a leftovers=(.zsh-pdf.*(N))
    (( ${#leftovers} == 0 ))
  }
  pdf_race() {
    stub gs 'for arg do case "$arg" in -sOutputFile=*) out=${arg#*=};; esac; done; printf original > raced.pdf; printf pdf > "$out"'
    pdfresize a.pdf raced.pdf && return 1
    [[ $(<raced.pdf) == original ]]
  }
  hardware_platforms() {
    stub sysctl 'case "$2" in hw.model|machdep.cpu.brand_string) printf "Generic CPU";; hw.physmem|hw.memsize) printf 2147483648;; *) exit 1;; esac'
    local platform output
    for platform in freebsd14 darwin24; do
      OSTYPE=$platform
      output=$(hardwareinfo) || return
      [[ $output == $'CPU: Generic CPU\nRAM: 2.0 GiB' ]] || return 1
    done
  }
  hardware_proc_platforms() {
    stub awk 'case "$*" in */proc/cpuinfo*) printf "Generic CPU";; */proc/meminfo*) printf 2.0;; *) exit 1;; esac'
    local platform output
    for platform in linux-gnu cygwin; do
      OSTYPE=$platform
      output=$(hardwareinfo) || return
      [[ $output == $'CPU: Generic CPU\nRAM: 2.0 GiB' ]] || return 1
    done
  }
  pdf_real_roundtrip() {
    /bin/rm -f "$work/bin/gs"
    rehash
    (( $+commands[gs] )) || return 77
    print -rl -- '%!PS' '72 72 moveto (Synthetic fixture) show showpage' > fixture.ps
    command gs -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=real-source.pdf fixture.ps || return
    pdfmerge real-source.pdf real-source.pdf || return
    pdfresize real-source-new.pdf real-small.pdf 150 || return
    command gs -q -dBATCH -dNOPAUSE -sDEVICE=nullpage real-small.pdf
  }
  real_dependency_skip() {
    local passed=0 failed=0 skipped=0
    path=("$work/no-tools")
    check PDF_MissingGhostscript pdf_real_roundtrip > "$work/skip-report"
    [[ $(<"$work/skip-report") == 'skip - PDF_MissingGhostscript (dependency unavailable)' ]] && (( passed == 0 && failed == 0 && skipped == 1 ))
  }
  spectrum_standalone() {
    source "$root/zshlib/spectrum.zsh"
    [[ -n $reset_color && ${#FG} == 256 && ${#BG} == 256 ]] || return
    setopt prompt_subst
    ZSH_SPECTRUM_TEXT='$(touch forbidden)'
    local -a lines=("${(@f)$(spectrum_ls)}")
    (( ${#lines} == 256 )) && [[ ! -e forbidden && -o prompt_subst ]] || return
    lines=("${(@f)$(spectrum_bls)}")
    (( ${#lines} == 256 )) && [[ ! -e forbidden ]]
  }
  download_args() {
    stub aria2c 'printf "%s\n" "$@" > "$TRACE"'
    dl 'https://example.invalid/file?a=1&b=2' "$PWD" || return
    [[ $(<"$TRACE") == *$'--\nhttps://example.invalid/file?a=1&b=2' ]] || return
    stub yt-dlp 'printf "%s\n" "$@" > "$TRACE"'
    yt 'https://example.invalid/video' || return
    [[ $(<"$TRACE") == *--no-overwrites* ]]
  }
  check Chmodx_Arguments chmod_arguments
  check Chmodx_FailureNoExecution chmod_failure
  check Shebang_ExistingAndDanglingProtected shebang_protected
  check Shebang_EditorArguments shebang_editor
  check Shebang_ExplicitEditorPathsAndNonexec shebang_editor_paths
  check Shebang_InterpreterValidation shebang_invalid
  check Bookmark_EditOnly bookmark_edit_only
  check PDF_OutputsAndFailureCleanup pdf_cases
  check PDF_RacingOutputProtected pdf_race
  check PDF_UnavailableDirectoryNoPathDisclosure pdf_directory_failure_private
  check Hardware_PlatformStubs hardware_platforms
  check Hardware_ProcPlatformStubs hardware_proc_platforms
  check PDF_MissingDependencyExplicitSkip real_dependency_skip
  check PDF_RealGhostscriptRoundtrip pdf_real_roundtrip
  check Spectrum_StandaloneNoSubstitution spectrum_standalone
  check Downloads_ArgumentsAndNoOverwrite download_args
  print "$passed passed; $failed failed; $skipped skipped"
  (( failed == 0 ))
)
