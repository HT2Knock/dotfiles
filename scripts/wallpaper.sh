#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/walle/images"
INTERVAL=900 # 15 minutes
STATE_FILE="/tmp/current_wallpaper"
PID_FILE="/tmp/wallpaper.pid"

pick_wallpaper() {
    fd . "$WALLPAPER_DIR" --type f | shuf -n 1
}

set_wallpaper() {
    local img="$1"

    if [[ "$img" == *.gif ]]; then
        swww img "$img" --transition-type "random"
    else
        swww img "$img" --reize "fit" --transition-type "random"
    fi

    echo "$img" >"$STATE_FILE"
}

delete_and_change() {
    if [[ -f "$STATE_FILE" ]]; then
        current=$(cat "$STATE_FILE")
        [[ -f "$current" ]] && rm "$current"
    fi
    set_wallpaper "$(pick_wallpaper)"
}

just_change() {
    set_wallpaper "$(pick_wallpaper)"
}

if [[ "$1" == "--skip" ]]; then
    [[ -f "$PID_FILE" ]] && kill -USR1 "$(cat "$PID_FILE")" || echo "No daemon running."
    exit 0
fi

if [[ "$1" == "--next" ]]; then
    [[ -f "$PID_FILE" ]] && kill -USR2 "$(cat "$PID_FILE")" || echo "No daemon running."
    exit 0
fi

echo $$ >"$PID_FILE"

trap delete_and_change USR1
trap just_change USR2

while true; do
    set_wallpaper "$(pick_wallpaper)"
    sleep "$INTERVAL" &
    wait $!
done
