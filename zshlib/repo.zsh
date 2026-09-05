# Commands act only on the explicitly selected remote; loading performs no I/O.
_repo_error() { print -u2 -- "repo: $1"; return 1; }

_repo_url_identity() {
  emulate -L zsh
  setopt extendedglob
  local value=$1 host route part
  local -a parts
  # Credentials, query strings and control characters are never accepted.
  case $value in
    https://*)
      value=${value#https://}
      [[ $value != *@* ]] || return 1
      host=${value%%/*}; route=${value#*/} ;;
    ssh://*)
      value=${value#ssh://}
      [[ $value == git@* ]] || return 1
      value=${value#git@}; host=${value%%/*}; route=${value#*/}
      host=${host%:22} ;;
    git@*:* )
      value=${value#git@}; host=${value%%:*}; route=${value#*:} ;;
    *) return 1 ;;
  esac
  [[ $host == [A-Za-z0-9]([A-Za-z0-9.:-])# ]] || return 1
  route=${route%.git}
  parts=("${(@s:/:)route}")
  (( ${#parts} >= 2 )) || return 1
  for part in "$parts[@]"; do
    [[ $part == [A-Za-z0-9_.-]## && $part != . && $part != .. ]] || return 1
  done
  [[ $host != github.com || ${#parts} == 2 ]] || return 1
  REPLY="${(L)host}/$route"
}

_repo_context() {
  emulate -L zsh
  setopt extendedglob
  local value configured
  local -a urls
  [[ $remote == [A-Za-z0-9]([A-Za-z0-9_.-])# ]] || { _repo_error 'invalid remote name'; return; }
  value=$(command git remote get-url --all "$remote" 2>/dev/null) || { _repo_error 'remote unavailable'; return; }
  urls=("${(@f)value}")
  (( ${#urls} == 1 )) && _repo_url_identity "$urls[1]" || { _repo_error 'ambiguous or unsupported fetch URL'; return; }
  identity=$REPLY
  forge=$(command git config --local --get "remote.$remote.forge" 2>/dev/null)
  web=$(command git config --local --get "remote.$remote.forgeWebUrl" 2>/dev/null)
  if [[ $identity == github.com/* && -z $forge ]]; then forge=github; fi
  case $forge in
    github)
      [[ $identity == github.com/* ]] || { _repo_error 'GitHub requires its canonical host'; return; }
      configured="https://$identity"
      [[ -z $web || $web == $configured ]] || { _repo_error 'web URL does not match repository'; return; }
      web=$configured ;;
    gitea)
      # Explicit mapping allows SSH aliases, HTTPS ports and server subpaths.
      [[ $web == https://* ]] || { _repo_error 'configure a credential-free forgeWebUrl locally'; return; }
      value=${web#https://}
      [[ $value == [A-Za-z0-9]([A-Za-z0-9._:/-])# && $value != *'//'* && $value != */../* && $value != */./* ]] || { _repo_error 'unsafe web URL'; return; }
      [[ $web == */${${identity:h}:t}/${identity:t} ]] || { _repo_error 'web repository does not match remote'; return; } ;;
    *) _repo_error 'configure remote forge and forgeWebUrl locally'; return ;;
  esac
}

# tea v0.14.1: login-list JSON has name/url keys; --repo and --login bind requests.
_repo_tea() {
  emulate -L zsh
  (( $+commands[tea] && $+commands[jq] )) || { _repo_error 'tea and jq are required for Gitea lists'; return; }
  login=$(command git config --local --get "remote.$remote.forgeLogin" 2>/dev/null)
  [[ -n $login && $login != *[[:cntrl:]]* ]] || { _repo_error 'configure forgeLogin locally'; return; }
  local data server
  data=$(command tea login list --output json </dev/null 2>/dev/null) || { _repo_error 'could not inspect tea login metadata'; return; }
  server=$(print -rn -- "$data" | command jq -er --arg login "$login" \
    'map(select(.name == $login)) | if length == 1 then .[0].url else error("ambiguous login") end' 2>/dev/null) || { _repo_error 'tea login missing or ambiguous'; return; }
  [[ ${server%/} == ${web:h:h} ]] || { _repo_error 'tea login does not match repository server'; return; }
  repo_slug="${${identity:h}:t}/${identity:t}"
}

_repo_browser() {
  emulate -L zsh
  case $OSTYPE in
    darwin*) (( $+commands[open] )) && command open "$1" >/dev/null 2>&1 ;;
    *) (( $+commands[xdg-open] )) && command xdg-open "$1" >/dev/null 2>&1 ;;
  esac
}

_repo_encode() {
  emulate -L zsh
  local LC_ALL=C char encoded='' byte
  for char in ${(s::)1}; do
    case $char in
      [a-zA-Z0-9.~_-]) encoded+=$char ;;
      *) printf -v byte '%%%02X' "'$char"; encoded+=$byte ;;
    esac
  done
  REPLY=$encoded
}

_repo_dispatch() {
  emulate -L zsh
  setopt extendedglob
  local action=$1 remote=origin base=main identity forge web REPLY branch value url number login repo_slug
  local -a urls
  shift
  while (( $# )); do
    case $1 in
      --remote) (( $# >= 2 )) || return 2; remote=$2; shift 2 ;;
      --base) [[ $action == pr && $# -ge 2 ]] || return 2; base=$2; shift 2 ;;
      *) print -u2 'usage: repo-open|repo-issues|repo-prs [--remote NAME]; repo-pr [--remote NAME] [--base BRANCH]'; return 2 ;;
    esac
  done
  _repo_context || return
  case $action in
    open) _repo_browser "$web" || { _repo_error 'browser could not be opened'; return; } ;;
    issues|prs)
      if [[ $forge == gitea ]]; then
        _repo_tea || return
        local entity=issues
        [[ $action == prs ]] && entity=pulls
        command tea "$entity" list --repo "$repo_slug" --login "$login" --fields index,title,state </dev/null 2>/dev/null || { _repo_error 'listing failed; check CLI authentication separately'; return; }
        return 0
      fi
      (( $+commands[gh] )) || { _repo_error 'gh is not installed'; return; }
      local entity=issue
      [[ $action == prs ]] && entity=pr
      GH_PROMPT_DISABLED=1 GH_PAGER=cat command gh "$entity" list --repo "$web" 2>/dev/null || { _repo_error 'listing failed; check CLI authentication separately'; return; } ;;
    pr)
      branch=$(command git symbolic-ref --quiet --short HEAD 2>/dev/null) || { _repo_error 'an attached branch is required'; return; }
      [[ $base != -* && $branch != -* && $branch != $base ]] &&
        command git check-ref-format "refs/heads/$base" >/dev/null 2>&1 &&
        command git check-ref-format "refs/heads/$branch" >/dev/null 2>&1 || { _repo_error 'invalid branch or current branch equals base'; return; }
      value=$(command git remote get-url --push --all "$remote" 2>/dev/null) || { _repo_error 'push destination unavailable'; return; }
      urls=("${(@f)value}")
      (( ${#urls} == 1 )) && _repo_url_identity "$urls[1]" && [[ $REPLY == $identity ]] || { _repo_error 'push destination is blocked, ambiguous or differs from fetch'; return; }
      command git -c push.followTags=false -c remote."$remote".mirror=false push --recurse-submodules=no -- "$remote" "refs/heads/${branch}:refs/heads/${branch}" >/dev/null 2>&1 || { _repo_error 'push failed; browser not opened'; return; }
      _repo_encode "$base"; url="$web/compare/$REPLY..."
      _repo_encode "$branch"; url+=$REPLY
      [[ $forge == github ]] && url+='?expand=1'
      if [[ $forge == github ]] && (( $+commands[gh] )); then
        number=$(GH_PROMPT_DISABLED=1 command gh pr list --repo "$web" --head "$branch" --base "$base" --state open --json number,isCrossRepository --jq '[.[] | select(.isCrossRepository == false)] | if length == 1 then .[0].number else empty end' 2>/dev/null)
        [[ $number == <-> ]] && url="$web/pull/$number"
      elif [[ $forge == gitea ]] && _repo_tea 2>/dev/null; then
        value=$(command tea pulls list --repo "$repo_slug" --login "$login" --state open --limit 100 --fields index,base,head --output json </dev/null 2>/dev/null)
        number=$(print -rn -- "$value" | command jq -er --arg base "$base" --arg head "$branch" \
          '[.[] | select(.base == $base and .head == $head)] | if length == 1 then .[0].index else empty end' 2>/dev/null)
        [[ $number == <-> ]] && url="$web/pulls/$number"
      fi
      _repo_browser "$url" || { _repo_error 'push succeeded, but browser could not be opened'; return; }
      print 'repo: push succeeded; complete or inspect the pull request in the browser' ;;
  esac
}

repo-open() { _repo_dispatch open "$@"; }
repo-issues() { _repo_dispatch issues "$@"; }
repo-prs() { _repo_dispatch prs "$@"; }
repo-pr() { _repo_dispatch pr "$@"; }
