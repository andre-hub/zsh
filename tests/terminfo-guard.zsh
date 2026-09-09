#!/usr/bin/env zsh
# Belegt den Uberspace-Fehlerfall: ohne Terminfo-Eintrag fuer $TERM startet zsh
# die Zeilenedition nicht, und Backspace, Pfeiltasten und Tab bleiben tot. Der
# Test stellt eine Terminfo-Datenbank ohne tmux-256color her und prueft an einer
# echten PTY, dass die Shell danach editierbar ist. Kein Zugriff auf die
# Terminfo-Datenbank des Rechners, keine Installation, keine Netzwerkzugriffe.
emulate -LR zsh
setopt err_exit no_unset
root=${0:A:h:h}
work=$(mktemp -d "$root/tests/.terminfo-guard.XXXXXXXX")
zmodload zsh/zpty
trap 'zpty -d terminfo-test 2>/dev/null || true; command rm -rf -- "$work"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

integer failed=0
(( $+commands[tic] && $+commands[infocmp] )) || {
  print -u2 'SKIP terminfo-guard: tic/infocmp fehlen'
  exit 0
}

# Ein Terminalname, den keine Datenbank dieses Rechners kennt, mit einer
# mitgelieferten Quelle daneben: das ist genau die Uberspace-Lage, ohne dass
# der Test die Terminfo-Datenbank des Rechners anfassen muesste.
probe=zsh-public-probe-256color
mkdir -p "$work/home" "$work/fixture-root/terminfo"
command infocmp -x tmux-256color \
  | sed "1,/^tmux-256color|/s/^tmux-256color|.*/$probe|zsh-public terminfo probe,/" \
  > "$work/fixture-root/terminfo/$probe.ti"
command infocmp "$probe" >/dev/null 2>&1 && {
  print -u2 "SKIP terminfo-guard: Sondenname $probe ist auf diesem Rechner belegt"
  exit 0
}

# Die ausgelieferte Quelle selbst muss uebersetzbar sein -- sie ist das
# Artefakt, das auf dem Zielhost eingespielt wird.
command tic -x -o "$work/shipped-check" "$root/terminfo/tmux-256color.ti" >/dev/null 2>&1 || {
  print -u2 'FAIL AK-T0: ausgeliefertes terminfo/tmux-256color.ti ist nicht uebersetzbar'
  exit 1
}
print 'PASS AK-T0_AusgelieferteQuelleUebersetzbar'

cat > "$work/home/.zshrc" <<'CHILD'
PROMPT='t> '
RPROMPT=''
HISTFILE=/dev/null
HISTSIZE=0
SAVEHIST=0
ZSH_PUBLIC_ROOT=$TEST_PUBLIC_ROOT
source "$TEST_ROOT/zshlib/terminfo-guard.zsh"
_test_capture() { print -r -- "$BUFFER" > "$TEST_CAPTURE"; zle kill-buffer }
zle -N _test_capture
bindkey '^X' _test_capture
print -r -- "TERM=$TERM" > "$TEST_READY"
CHILD

start_shell() {
  local term=$1
  command rm -f -- "$work/ready" "$work/capture"
  zpty -b terminfo-test env -i HOME="$work/home" ZDOTDIR="$work/home" \
    PATH=/usr/bin:/bin TERM="$term" LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    TEST_ROOT="$root" TEST_PUBLIC_ROOT="$2" \
    TEST_READY="$work/ready" TEST_CAPTURE="$work/capture" \
    zsh -d -i
  local attempt chunk
  for attempt in {1..250}; do
    [[ -f $work/ready ]] && return 0
    while zpty -r terminfo-test chunk 2>/dev/null; do :; done
    sleep 0.02
  done
  return 1
}

stop_shell() { zpty -d terminfo-test 2>/dev/null || true }

# Echte Zeilenedition: "abcX" tippen, zweimal Backspace, Rest in die
# Belegdatei schreiben. Kommt "ab" an, hat ZLE die Tasten verarbeitet.
check_zle() {
  local label=$1 expected=$2 attempt chunk actual
  zpty -w -n terminfo-test $'abcX\177\177\C-x'
  for attempt in {1..250}; do
    [[ -f $work/capture ]] && break
    while zpty -r terminfo-test chunk 2>/dev/null; do :; done
    sleep 0.02
  done
  [[ -f $work/capture ]] || { print -u2 -r -- "FAIL $label: ZLE antwortet nicht"; return 1 }
  actual=$(<"$work/capture")
  [[ $actual == "$expected" ]] || {
    print -u2 -r -- "FAIL $label: Puffer ${(qqq)actual} statt ${(qqq)expected}"; return 1 }
  print -r -- "PASS $label"
}

term_of_child() { print -r -- "${$(<"$work/ready")#TERM=}" }

# Fall 1: mitgelieferte Quelle vorhanden -> benutzerlokal einspielen, $TERM bleibt.
start_shell "$probe" "$work/fixture-root" || { print -u2 'FAIL AK-T1: Start ohne Terminfo blockiert'; failed=1 }
if (( ! failed )); then
  [[ $(term_of_child) == "$probe" ]] || {
    print -u2 -r -- "FAIL AK-T1: TERM wurde auf $(term_of_child) geaendert"; failed=1 }
  [[ -n $(print -rn -- $work/home/.terminfo/*/$probe(N)) ]] || {
    print -u2 'FAIL AK-T1: kein benutzerlokaler Eintrag angelegt'; failed=1 }
  check_zle AK-T1_ZleLebt ab || failed=1
fi
stop_shell

# Fall 2: unbekannter Name ohne mitgelieferte Quelle -> Ausweichen, Shell bleibt nutzbar.
command rm -rf -- "$work/home/.terminfo"
start_shell nicht-existentes-terminal-xyz "$work/fixture-root" || { print -u2 'FAIL AK-T2: Start blockiert'; failed=1 }
if (( ! failed )); then
  [[ $(term_of_child) == nicht-existentes-terminal-xyz ]] && {
    print -u2 'FAIL AK-T2: unbekanntes TERM unveraendert gelassen'; failed=1 }
  check_zle AK-T2_ZleLebt ab || failed=1
fi
stop_shell

# Fall 3: aufloesbares TERM -> unveraendert, kein Eintrag angelegt.
command rm -rf -- "$work/home/.terminfo"
start_shell xterm "$work/fixture-root" || { print -u2 'FAIL AK-T3: Start blockiert'; failed=1 }
if (( ! failed )); then
  [[ $(term_of_child) == xterm ]] || {
    print -u2 -r -- "FAIL AK-T3: TERM unnoetig auf $(term_of_child) geaendert"; failed=1 }
  [[ -e $work/home/.terminfo ]] && { print -u2 'FAIL AK-T3: unnoetiger Terminfo-Schreibzugriff'; failed=1 }
  check_zle AK-T3_ZleLebt ab || failed=1
fi
stop_shell

(( failed )) && { print -u2 'FAIL terminfo-guard'; exit 1 }
print 'PASS terminfo-guard'
