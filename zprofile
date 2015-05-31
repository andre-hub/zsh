/usr/bin/keychain $HOME/.ssh/id_rsa
source $HOME/.keychain/$HOST-sh

export GOPATH=$HOME/workspace/go
export PATH=$PATH:$GOPATH/bin
#export GOROOT=$HOME/go
#export PATH=$PATH:$GOROOT/bin

if [ "$(tty)" = "/dev/tty2" ]; then 
	startxfce4
fi