# Compatibility entry point; keep one definition of the selected shortcuts.
() {
  local root=${${(%):-%x}:A:h:h}
  local definitions=$root/zshlib/aliases.zsh
  [[ -f $definitions && ${definitions:A} == $definitions ]] || return 1
  source "$definitions"
}
