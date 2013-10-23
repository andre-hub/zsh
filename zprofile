if [ "$(tty)" = "/dev/tty1" ]; then 
	startxfce4
fi

export GOPATH=$HOME/workspace/go
export PATH=$PATH:$GOPATH/bin
#export GOROOT=$HOME/go
#export PATH=$PATH:$GOROOT/bin
