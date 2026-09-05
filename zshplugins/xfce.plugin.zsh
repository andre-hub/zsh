# Do not replace a browser shortcut on a headless server.
if [[ -n ${DISPLAY:-}${WAYLAND_DISPLAY:-} ]] && (( $+commands[thunar] )); then
    alias browse='thunar'
fi
return 0
