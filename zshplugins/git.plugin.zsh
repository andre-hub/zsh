# Small standalone Git helpers; no Python status process or automatic hooks.
# git_super_status keeps the name used by the former zsh-git-prompt integration:
# https://github.com/olivierverdier/zsh-git-prompt

current_branch() {
    emulate -L zsh
    command git symbolic-ref --quiet --short HEAD 2>/dev/null ||
        command git rev-parse --short HEAD 2>/dev/null
}

git_root() {
    emulate -L zsh
    command git rev-parse --show-toplevel 2>/dev/null
}

# Use $(git_super_status) in a prompt with PROMPT_SUBST enabled.
# Escape percent signs from branch names so they are not prompt directives.
git_super_status() {
    emulate -L zsh
    local branch
    branch=$(current_branch) || return 0
    print -r -- "(${branch//\%/%%})"
}
