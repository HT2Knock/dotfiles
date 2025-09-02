#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/walle/images"

# Generate a randomized list of all files and select one
img=$(find "$WALLPAPER_DIR" -type f |
    while read -r file; do
        echo "$(</dev/urandom tr -dc 0-9 | head -c 8):$file"
    done |
    sort -n | cut -d':' -f2- | head -n 1)

# Set the wallpaper if an image was found
[ -n "$img" ] && swww img "$img" --transition-type center
