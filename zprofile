/usr/bin/keychain $HOME/.ssh/id_rsa
source $HOME/.keychain/$HOST-sh

export TMPDIR=/tmp

export GOPATH=$HOME/workspace/go
export PATH=$PATH:$GOPATH/bin
export PATH="$HOME/.cargo/bin:$PATH"

# export PATH="/usr/share/yarn/bin:$PATH"
# export PATH="/usr/share/yarn/bin/node-gyp-bin:$PATH"

if [ "$(tty)" = "/dev/tty2" ]; then 
	startxfce4
fi

# TODO.txt
export TODO_DIR="$HOME/Documents/Nextcloud"
export TODO_FILE="$TODO_DIR/todo.txt"
export DONE_FILE="$TODO_DIR/done.txt"

# Proxy
#export http_proxy=http://rpi2:8888
# export https_proxy=http://rpi2:8888
#export ftp_proxy=http://rpi2:8888
#export HTTP_PROXY=$http_proxy
# export HTTPS_PROXY=$https_proxy
#export FTP_PROXY=$ftp_proxy
#export no_proxy=example.com,192.168.1.1,192.168.178.1,local