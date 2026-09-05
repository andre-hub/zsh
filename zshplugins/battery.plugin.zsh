# Optional battery helpers; no probes are made while loading the plugin.
# Linux: acpi; macOS: pmset; FreeBSD: acpiconf. First battery only.
_zsh_battery_read() {
    emulate -L zsh
    case $OSTYPE in
        linux*) (( $+commands[acpi] )) && command acpi -b 2>/dev/null ;;
        darwin*) (( $+commands[pmset] )) && command pmset -g batt 2>/dev/null ;;
        freebsd*) (( $+commands[acpiconf] )) && command acpiconf -i 0 2>/dev/null ;;
        *) return 1 ;;
    esac
}
battery_pct() {
    emulate -L zsh
    local data=$(_zsh_battery_read) line value
    for line in "${(@f)data}"; do
        [[ $line == *%* ]] || continue
        value=${line%%\%*}
        value=${value##*[^0-9]}
        [[ $value == <-> ]] && (( value <= 100 )) || continue
        print -r -- "$value"
        return 0
    done
    return 1
}
battery_is_charging() {
    emulate -L zsh
    local data=$(_zsh_battery_read) line
    for line in "${(@f)data}"; do
        case $OSTYPE in
            linux*) [[ $line == Battery* ]] || continue ;;
            darwin*) [[ $line == *%* ]] || continue ;;
            freebsd*) [[ $line == State:* ]] || continue ;;
        esac
        [[ ${line:l} == *charging* && ${line:l} != *discharging* && ${line:l} != *'not charging'* ]]
        return
    done
    return 1
}
battery_pct_remaining() {
    local value=$(battery_pct)
    [[ -n $value ]] || return 1
    if battery_is_charging; then print -r -- 'External Power'; else print -r -- "$value"; fi
}
battery_time_remaining() {
    emulate -L zsh
    local data=$(_zsh_battery_read) line
    for line in "${(@f)data}"; do
        if [[ $line =~ '([0-9]+:[0-9][0-9](:[0-9][0-9])?)' ]]; then
            print -r -- "$match[1]"
            return 0
        fi
    done
    return 1
}
battery_pct_prompt() {
    local value=$(battery_pct) color
    [[ $value == <-> ]] || return 0
    if (( value > 50 )); then color=green
    elif (( value > 20 )); then color=yellow
    else color=red
    fi
    print -r -- "%F{$color}${value}%%%f"
}
battery_level_gauge() {
    emulate -L zsh
    local value=$(battery_pct)
    [[ $value == <-> ]] || return 0
    local slots=${BATTERY_GAUGE_SLOTS:-10} i filled color
    [[ $slots == <-> ]] && (( slots > 0 && slots <= 100 )) || return 2
    filled=$(( (value * slots + 99) / 100 ))
    if (( value > 60 )); then color=${BATTERY_COLOR_GREEN:-'%F{green}'}
    elif (( value > 40 )); then color=${BATTERY_COLOR_YELLOW:-'%F{yellow}'}
    else color=${BATTERY_COLOR_RED:-'%F{red}'}
    fi
    battery_is_charging && print -rn -- "${BATTERY_CHARGING_SYMBOL:-⚡}"
    print -rn -- "${BATTERY_GAUGE_PREFIX:-[}${color}"
    for (( i=0; i<slots; i++ )); do
        if (( i < filled )); then print -rn -- "${BATTERY_GAUGE_FILLED_SYMBOL:-▶}"
        else print -rn -- "${BATTERY_GAUGE_EMPTY_SYMBOL:-▷}"
        fi
    done
    print -rn -- "%f${BATTERY_GAUGE_SUFFIX:-]}"
}
