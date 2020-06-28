sql() {
    cmd="psql -X -P linestyle=unicode -P null=NULL servername"
    f="$HOME/workspace/it/sql.git/scripts/$1"
    if [[ -f "$f" ]]; then
        eval "$cmd" < "$HOME/workspace/it/sql.git/scripts/$1" | less -S
    else
        eval "$cmd" <<< "$1" | less -S
    fi
}
_sql() { _files -W $HOME/workspace/it/sql.git/scripts }
compdef _sql sql
