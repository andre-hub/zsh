# Prefer the non-deprecated extended/fixed-pattern forms.
alias egrep='grep -E'
alias fgrep='grep -F'
if command grep --color=auto '' </dev/null >/dev/null 2>&1; then
  alias grep='grep --color=auto'
elif [[ $OSTYPE == linux* ]]; then
  # An empty input returns 1 even when --color is supported.
  alias grep='grep --color=auto'
fi
