# Initialize completion without dumping state or loading insecure directories.
autoload -Uz compinit
compinit -i -D

zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end

bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

: ${ZSH_CACHE_DIR:="${XDG_CACHE_HOME:-$HOME/.cache}/zsh-public"}
[[ -d "$ZSH_CACHE_DIR" ]] || (umask 077; command mkdir -p -- "$ZSH_CACHE_DIR")
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$ZSH_CACHE_DIR"

zstyle ':completion:*:*:*:users' ignored-patterns \
    adm amanda apache at avahi avahi-autoipd bin cacti clamav daemon dbus \
    distcache dnsmasq dovecot fax ftp games gdm gkrellmd gopher hacluster \
    haldaemon halt hsqldb ident junkbust kdm ldap lp mail mailman mailnull \
    man messagebus mldonkey mysql nagios named netdump news nfsnobody nobody \
    nscd ntp nut nx obsrun openvpn operator pcap polkitd postfix postgres \
    privoxy pulse pvm quagga radvd rpc rpcuser rpm rtkit scard shutdown squid \
    sshd statd svn sync tftp usbmux uucp vcsa wwwrun xfs '_*'

zstyle '*' single-ignored show
