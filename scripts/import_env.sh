#!/usr/bin/env bash
set -eo pipefail

# Skip if Hyprland is in debug mode
[[ -n $HYPRLAND_DEBUG_CONF ]] && exit 0

# Core environment variables for Hyprland + Wayland apps + tmux
_envs=(
    # Displays
    WAYLAND_DISPLAY
    DISPLAY
    # XDG session info
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
    # Desktop configs
    XCURSOR_SIZE
    XCURSOR_THEME
    # Toolkit configs
    QT_QPA_PLATFORM
    QT_WAYLAND_DISABLE_WINDOWDECORATION
    QT_AUTO_SCREEN_SCALE_FACTOR
    GDK_BACKEND
    # SSH agent
    SSH_AUTH_SOCK
    # Path
    PATH
)

echo "Importing environment variables..."

# Import to systemd/dbus
dbus-update-activation-environment --systemd "${_envs[@]}"

# Import to tmux (only if tmux is running)
if command -v tmux >/dev/null 2>&1 && tmux info >/dev/null 2>&1; then
    for v in "${_envs[@]}"; do
        if [[ -n ${!v} ]]; then
            tmux setenv -g "$v" "${!v}"

            for s in $(tmux list-sessions -F '#S' 2>/dev/null); do
                tmux setenv -t "$s" "$v" "${!v}" 2>/dev/null || true
            done
        fi
    done
    echo "Environment synced to tmux"
fi

echo "Environment import complete"
