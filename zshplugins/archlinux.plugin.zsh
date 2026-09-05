# Pacman only: obsolete AUR helpers and automatic key imports are omitted.
[[ $OSTYPE == linux* ]] && (( $+commands[pacman] )) || return 0
_zsh_pacman_root() {
    if (( EUID == 0 )); then
        command pacman "$@"
    elif (( $+commands[sudo] )); then
        command sudo pacman "$@"
    else
        print -u2 'This operation requires root or sudo.'
        return 1
    fi
}
alias pacupg='_zsh_pacman_root -Syu'
alias pacin='_zsh_pacman_root -S'
alias pacins='_zsh_pacman_root -U'
alias pacre='_zsh_pacman_root -R'
alias pacrem='_zsh_pacman_root -Rns'
alias pacrep='pacman -Si'
alias pacreps='pacman -Ss'
alias pacloc='pacman -Qi'
alias paclocs='pacman -Qs'
alias pacinsd='_zsh_pacman_root -S --asdeps'
alias paclsorphans='pacman -Qdt'
alias pacfileupg='_zsh_pacman_root -Fy'
alias pacfiles='pacman -Fs'
# Always use a full system upgrade, never a partial -Sy refresh.
alias pacupd='_zsh_pacman_root -Syu'
return 0
