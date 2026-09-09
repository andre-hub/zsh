# Kennt der Zielhost den Terminfo-Eintrag fuer $TERM nicht, faellt die
# Terminalbeschreibung auf einen Notbehelf zurueck: Farben, Tastenfolgen und
# Terminalfaehigkeiten stimmen dann nicht mehr mit dem an, was das Terminal
# tatsaechlich sendet. Auf frisch aufgesetzten Hosts wie Uberspace ist genau
# das der Normalfall, weil der lokale tmux TERM=tmux-256color exportiert, die
# dortige ncurses-Datenbank diesen Eintrag aber nicht kennt.
#
# Reihenfolge, absichtlich in dieser Rangfolge:
#   1. Ist $TERM in einer Terminfo-Datenbank vorhanden, passiert nichts. Kein
#      unbedingter TERM-Override.
#   2. Liegt fuer genau dieses $TERM eine mitgelieferte Terminfo-Quelle bei,
#      wird sie benutzerlokal nach ~/.terminfo eingespielt. Der Eintrag bleibt
#      danach dauerhaft vorhanden, auch fuer alle anderen Programme.
#   3. Erst wenn auch das scheitert (kein tic, kein Schreibrecht, keine
#      passende Quelle), weicht diese Datei als letzter Ausweg auf den
#      naechstbesten tatsaechlich vorhandenen Eintrag aus. Ein korrekt
#      beschriebenes Terminal ist mehr wert als ein exakter, aber nirgends
#      hinterlegter Terminalname.
#
# Die Pruefung liest die Datenbankdateien direkt statt `infocmp` aufzurufen:
# das kostet keinen Prozessstart pro Shell und funktioniert auch dort, wo die
# ncurses-Werkzeuge fehlen. Sie bildet die Suchreihenfolge von ncurses nach,
# einschliesslich der Hex-Unterverzeichnisse mancher Systeme (FreeBSD, macOS).

() {
  emulate -L zsh
  setopt local_options no_unset

  # dumb und ein leeres TERM sind bewusste Angaben und werden nie angefasst.
  [[ -n $TERM && $TERM != dumb ]] || return 0

  # $TERM kommt bei einer SSH-Sitzung von der Gegenstelle. Bevor der Wert in
  # einen Dateipfad oder in eine Meldung geht, muss er die Form eines
  # Terminalnamens haben: kein Schraegstrich, keine Traversierung, keine
  # Steuerzeichen. Alles andere wird nicht repariert, sondern in Ruhe gelassen.
  [[ $TERM == [A-Za-z0-9]* && $TERM != *[^A-Za-z0-9._+-]* ]] || return 0

  local -a search
  search=(
    ${TERMINFO:+$TERMINFO}
    $HOME/.terminfo
    ${(s.:.)${TERMINFO_DIRS:-}}
    /etc/terminfo /lib/terminfo /usr/share/terminfo
    /usr/lib/terminfo /usr/local/share/terminfo
  )

  _zsh_terminfo_present() {
    local name=$1 dir
    local initial=${name[1]}
    local hex
    printf -v hex '%02x' "$((#initial))"
    for dir in $search; do
      [[ -n $dir ]] || dir=/usr/share/terminfo
      [[ -f $dir/$initial/$name || -f $dir/$hex/$name ]] && return 0
    done
    return 1
  }

  if _zsh_terminfo_present "$TERM"; then
    unset -f _zsh_terminfo_present
    return 0
  fi

  local wanted=$TERM
  local source=${ZSH_PUBLIC_ROOT:-${${(%):-%N}:A:h:h}}/terminfo/$wanted.ti

  if [[ -r $source ]] && (( $+commands[tic] )); then
    if command tic -x -o "$HOME/.terminfo" -- "$source" >/dev/null 2>&1 \
       && _zsh_terminfo_present "$wanted"; then
      unset -f _zsh_terminfo_present
      return 0
    fi
  fi

  local candidate
  for candidate in screen-256color screen xterm-256color xterm vt100; do
    if _zsh_terminfo_present "$candidate"; then
      export TERM=$candidate
      unset -f _zsh_terminfo_present
      # ${(V)...}: ein von der Gegenstelle gesetzter Name darf keine
      # Steuerzeichen unsichtbar ins Terminal schreiben.
      print -u2 -r -- "zsh: kein Terminfo fuer '${(V)wanted}'; benutze '$candidate'."
      return 0
    fi
  done

  unset -f _zsh_terminfo_present
}
