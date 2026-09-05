# Explicit terminal refresh for an existing GnuPG setup; no agent is started.
gpg_tty_refresh() {
    emulate -L zsh
    [[ -t 0 ]] || return 1
    local terminal
    terminal=$(command tty) || return
    export GPG_TTY=$terminal
}
