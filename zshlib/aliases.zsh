###########         Aliases         ###########
deviceWlan=wlp52s0

# Super user
alias _='sudo'

# Show history
alias history='fc -l 1'

hash -d RC=/etc/rc.d/      # executed files from init (Slackware)
hash -d RC=/etc/conf.d/    # Init-Files from init (Gentoo)
hash -d RC=/etc/init.d/    # executed files from init (Gentoo, Debian, ..)

# nice tiny commands
alias ht="htop"
alias rsync="rsync --human-readable  --progress --recursive -t"
alias insecssh='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null"'
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias gitgc="gitg -c"
alias gitga="gitg -a"
alias wlanpower="sudo iwconfig $deviceWlan power"
alias wlanshow="sudo iwconfig $deviceWlan | egrep -i 'ieee|power'"
alias ip="ip --color"
alias ipb="ip --color --brief"


# start editor by extension
alias -s txt='vim'
alias -s conf='vim'
alias -s cnf='vim'
alias -s go='vim'
alias -s php='vim'
alias -s css='vim'
alias -s xml='vim'
# start default applications by extension
alias -s pdf='evince'
alias -s ods='soffice'
alias -s odp='soffice'
alias -s doc='soffice'
alias -s jpeg='ristretto'
alias -s jpg='ristretto'
alias -s png='ristretto'