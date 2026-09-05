# Debian package shortcuts. Nothing runs until a shortcut is invoked.
[[ $OSTYPE == linux* && -r /etc/debian_version ]] || return 0
(( $+commands[apt-get] )) || return 0

# apt_pref may be apt, apt-get or aptitude; never evaluate command strings.
: ${apt_pref:=apt-get}
_zsh_debian_root() {
    emulate -L zsh
    if (( EUID == 0 )); then
        command "$@"
    elif (( $+commands[sudo] )); then
        command sudo "$@"
    else
        print -u2 'This operation requires root or sudo.'
        return 1
    fi
}
_zsh_debian_apt() {
    emulate -L zsh
    case $apt_pref in
        apt|apt-get|aptitude) _zsh_debian_root "$apt_pref" "$@" ;;
        *) print -u2 'apt_pref must be apt, apt-get or aptitude.'; return 2 ;;
    esac
}
alias aac='_zsh_debian_apt autoclean'
alias abd='_zsh_debian_apt build-dep'
alias ac='_zsh_debian_apt clean'
alias ad='_zsh_debian_apt update'
alias adg='_zsh_debian_apt update && _zsh_debian_apt upgrade'
alias adu='_zsh_debian_apt update && _zsh_debian_apt dist-upgrade'
alias ag='_zsh_debian_apt upgrade'
alias ar='_zsh_debian_apt remove'
alias apt-install='_zsh_debian_apt install'
alias apt-purge='_zsh_debian_apt purge'
alias acs='apt-cache search'
alias acsv='apt-cache show'
alias ap='apt-cache policy'
alias asrc='apt-get source'
alias allpkgs="dpkg-query -f '\${Package}\\n' -W"
(( $+commands[aptitude] )) && alias at='aptitude'
(( $+commands[apt-file] )) && alias afs='apt-file search --regexp'
(( $+commands[dpkg-buildpackage] )) && alias mydeb='dpkg-buildpackage -us -uc'
ins() { _zsh_debian_apt install "$@"; }
apt-date() {
    _zsh_debian_apt update && _zsh_debian_apt upgrade &&
        _zsh_debian_apt autoremove && _zsh_debian_apt autoclean
}
# Output is reusable by packagerestore; redirect explicitly to save it.
packagelist() { command dpkg --get-selections; }
packagerestore() {
    (( $# == 1 )) && [[ -r $1 ]] || { print -u2 'Usage: packagerestore FILE'; return 2; }
    _zsh_debian_root dpkg --set-selections < "$1" &&
        _zsh_debian_root apt-get dselect-upgrade
}
packageinstall() {
    emulate -L zsh
    (( $# == 2 )) && [[ -r $1 ]] || { print -u2 'Usage: packageinstall FILE single|all'; return 2; }
    [[ $2 == (single|allein|all|alles) ]] || return 2
    local package
    local -a packages
    while IFS= read -r package || [[ -n $package ]]; do
        [[ -z $package || $package == \#* ]] && continue
        # One package per line, not arbitrary apt options or shell syntax.
        [[ $package == [a-z0-9]* && $package != *[^a-z0-9+.:_-]* ]] || return 2
        packages+=("$package")
    done < "$1"
    (( ${#packages} )) || return 0
    if [[ $2 == (single|allein) ]]; then
        for package in "${packages[@]}"; do
            _zsh_debian_apt install "$package" || return
        done
    else
        _zsh_debian_apt install "${packages[@]}"
    fi
}
return 0
