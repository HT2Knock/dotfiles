#!/usr/bin/env bash
set -eo pipefail

# Skip if Hyprland is in debug mode
[[ -n $HYPRLAND_DEBUG_CONF ]] && exit 0

USAGE="\
Import environment variables 

Usage: $0 <command>

Commands:
   tmux         import to tmux server
   system       import to systemd and dbus user session
   help         print this help
"

# Core environment variables needed for Hyprland + Wayland apps + tmux
_envs=(
    # Displays
    WAYLAND_DISPLAY
    DISPLAY

    # XDG session info (important for portals, apps, systemd services)
    XDG_BACKEND
    XDG_CURRENT_DESKTOP
    XDG_SESSION_TYPE
    XDG_SESSION_ID
    XDG_SESSION_CLASS
    XDG_SESSION_DESKTOP
    XDG_SEAT
    XDG_VTNR

    # Hyprland specific
    HYPRLAND_CMD
    HYPRLAND_INSTANCE_SIGNATURE

    # Misc desktop configs
    XCURSOR_SIZE

    # Toolkit quirks (Qt, screenshots)
    QT_QPA_PLATFORM
    QT_WAYLAND_DISABLE_WINDOWDECORATION

    # SSH agent
    SSH_AUTH_SOCK
)

case "$1" in
system)
    # Sync to dbus + systemd user services (Wayland portals, notifications, etc.)
    dbus-update-activation-environment --systemd "${_envs[@]}"
    ;;
tmux)
    # Push into tmux global env so new panes/sessions see the vars
    for v in "${_envs[@]}"; do
        if [[ -n ${!v} ]]; then
            tmux setenv -g "$v" "${!v}"
        fi

        for s in $(tmux list-sessions -F '#S'); do
            tmux setenv -t "$s" "$v" "${!v}"
        done

        # optional: show what was updated (quiet if not interactive)
        [[ -t 1 ]] && echo "Updated $v=${!v}"
    done
    ;;
help)
    echo -n "$USAGE"
    exit 0
    ;;
*)
    echo "operation required"
    echo "use \"$0 help\" to see usage help"
    exit 1
    ;;
esac
