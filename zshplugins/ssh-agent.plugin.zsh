# Use an existing agent socket explicitly, without starting agents or loading keys.
# Never sources cached shell code or alters forwarded sockets at startup.
ssh_agent_use() {
    emulate -L zsh
    if (( $# != 1 )) || [[ ! -S $1 ]]; then
        print -u2 -- 'Usage: ssh_agent_use SOCKET (an existing Unix socket)'
        return 2
    fi
    export SSH_AUTH_SOCK=$1
    unset SSH_AGENT_PID
}
