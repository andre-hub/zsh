# Explicit tmux shortcuts only: sourcing never starts or attaches a session.
[[ -o interactive ]] || return 0
(( $+commands[tmux] )) || return 0
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'
