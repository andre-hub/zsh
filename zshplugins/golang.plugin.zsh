# Go aliases, with completion maintained by the installed Zsh distribution.
# Replaces the obsolete 5g/6g/8g and godoc-template completion machinery.
if (( $+functions[compdef] )); then
    autoload -Uz _go
    compdef _go go
fi

alias gob='go build'
alias goc='go clean'
alias god='go doc'
alias gof='go fmt'
alias gofa='go fmt ./...'
alias gog='go get'
alias goi='go install'
alias gol='go list'
alias gom='go mod'
alias gomt='go mod tidy'
alias gomv='go mod vendor'
alias gor='go run'
alias got='go test'
alias gota='go test ./...'
alias gotr='go test -race ./...'
alias gov='go vet'
alias gova='go vet ./...'
