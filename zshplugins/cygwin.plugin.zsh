[[ $OSTYPE == cygwin* ]] || return 0
(( $+commands[explorer] )) && alias browse='explorer .'
if (( $+commands[cygstart] )); then
    sln() {
        emulate -L zsh
        local -a solutions=( **/*.sln(N) )
        (( $# )) && solutions=( "$@" )
        (( ${#solutions} == 1 )) || {
            print -u2 'Usage: sln FILE (or run in a tree with exactly one solution)'
            return 2
        }
        command cygstart "${solutions[1]}"
    }
fi
return 0
