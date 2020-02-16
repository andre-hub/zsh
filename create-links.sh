#!/bin/sh
#
baseDirectory="$HOME/workspace/it/zsh.git"

createLinkFile () {
	echo "target: $1"
	rm $2 
	ln -s $1 $2
}

createLinkDirectory () {
	echo "target: $1"
	rm -rf $2 
	ln -s $1 $2
}

createLinkDirectory $baseDirectory/zshlib $HOME/.zshlib
createLinkDirectory $baseDirectory/zshplugins $HOME/.zshplugins
createLinkDirectory $baseDirectory/zsh-syntax-highlighting $HOME/.zsh-syntax-highlighting
createLinkFile $baseDirectory/zlogout $HOME/.zlogout
createLinkFile $baseDirectory/zprofile $HOME/.zprofile
createLinkFile $baseDirectory/zshrc $HOME/.zshrc