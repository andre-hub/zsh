# PostgreSQL client with readable output; no predefined database or credentials.
# Supply normal psql arguments, e.g. sql -d DATABASE -f query.sql.
sql() {
    emulate -L zsh
    command psql -X -P linestyle=unicode -P null=NULL "$@"
}
if (( $+functions[compdef] )); then
    compdef sql=psql
fi
