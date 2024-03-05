#!/bin/bash

SOURCE_DIR="$HOME/Pictures/aesthetic-wallpapers/images"

# Check if SOURCE_DIR exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR not found." >&2
    exit 1
fi

# Change directory to SOURCE_DIR
cd "$SOURCE_DIR" || exit 1

# Select a random image file
img_name=$(find . \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0 | shuf -zn 1)

# Check if img_name is empty
if [ -z "$img_name" ]; then
    echo "Error: No image files found in $SOURCE_DIR." >&2
    exit 1
fi

# Set desktop background
feh --bg-scale "${img_name}"
