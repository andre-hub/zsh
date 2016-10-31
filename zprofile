/usr/bin/keychain $HOME/.ssh/id_rsa
source $HOME/.keychain/$HOST-sh

export TMPDIR=/tmp

export GOPATH=$HOME/workspace/go
export PATH=$PATH:$GOPATH/bin
export PATH="/usr/share/yarn/bin:$PATH"
export PATH="/usr/share/yarn/bin/node-gyp-bin:$PATH"
#export GOROOT=$HOME/go
#export PATH=$PATH:$GOROOT/bin

if [ "$(tty)" = "/dev/tty2" ]; then 
	startxfce4
fi