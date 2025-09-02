#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/walle/images"
INTERVAL=900 # 15 minutes

while true; do
    # Generate a randomized list of all files
    find "$WALLPAPER_DIR" -type f |
        while read -r img; do
            echo "$(</dev/urandom tr -dc 0-9 | head -c 8):$img"
        done |
        sort -n | cut -d':' -f2- |
        while read -r img; do
            [ -n "$img" ] && swww img "$img" \
                --resize fit \
                --transition-type center \
                --transition-fps 60 \
                --transition-step 2
            sleep "$INTERVAL"
        done
done
