# Repository-local configuration. No external plugin loader.
[[ -o interactive ]] || return 0

# :A resolves the installed .zshrc symlink back into this checkout.
typeset -g ZSH_PUBLIC_ROOT=${${(%):-%N}:A:h}
typeset -U path
for _zsh_public_dir in /usr/local/bin /usr/local/sbin /opt/homebrew/bin /opt/homebrew/sbin; do
  [[ -d $_zsh_public_dir ]] && path+=("$_zsh_public_dir")
done
export PATH

typeset -ga _zsh_loaded_modules
for _zsh_public_module in \
  terminfo-guard.zsh \
  completion.zsh directories.zsh history.zsh key-bindings.zsh \
  edit-command-line.zsh misc.zsh grep.zsh theme-and-appearance.zsh \
  git.zsh functions.zsh packer.zsh aliases.zsh \
  media.zsh repo.zsh spectrum.zsh; do
  [[ :${ZSH_PUBLIC_DISABLE_MODULES:-}: == *:${_zsh_public_module}:* ]] && continue
  _zsh_public_file=$ZSH_PUBLIC_ROOT/zshlib/$_zsh_public_module
  if [[ ${_zsh_public_file:A} == $ZSH_PUBLIC_ROOT/zshlib/* && -f $_zsh_public_file ]]; then
    (( ${_zsh_loaded_modules[(Ie)${_zsh_public_file:A}]} )) && continue
    source "$_zsh_public_file"
    _zsh_loaded_modules+=("${_zsh_public_file:A}")
  fi
done
# Optional plugins must be selected by name and remain within this checkout.
typeset -ga _zsh_loaded_plugins
for _zsh_public_plugin in "${(@s.:.)${ZSH_PUBLIC_PLUGINS:-}}"; do
  [[ -n $_zsh_public_plugin ]] || continue
  _zsh_public_file=$ZSH_PUBLIC_ROOT/zshplugins/$_zsh_public_plugin
  if [[ ${_zsh_public_file:A} == $ZSH_PUBLIC_ROOT/zshplugins/* && -f $_zsh_public_file ]]; then
    (( ${_zsh_loaded_plugins[(Ie)${_zsh_public_file:A}]} )) && continue
    if source "$_zsh_public_file"; then
      _zsh_loaded_plugins+=("${_zsh_public_file:A}")
    else
      print -u2 'zsh: selected plugin failed to load.'
    fi
  else
    print -u2 'zsh: selected plugin missing or outside repository plugin directory.'
  fi
done
unset _zsh_public_dir _zsh_public_module _zsh_public_plugin _zsh_public_file
