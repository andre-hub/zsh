# Keep the login environment supplied by the OS, SSH or service manager.
# Add existing package-manager paths without changing their precedence.
typeset -U path
for _zsh_public_dir in /usr/local/bin /usr/local/sbin /opt/homebrew/bin /opt/homebrew/sbin; do
  [[ -d $_zsh_public_dir ]] && path+=("$_zsh_public_dir")
done
export PATH
unset _zsh_public_dir
