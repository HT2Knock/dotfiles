#!/bin/bash

SOURCE_DIR="$HOME/Pictures/walle/images"

# Check if SOURCE_DIR exists
if [ ! -d "$SOURCE_DIR" ]; then
	echo "Error: Source directory $SOURCE_DIR not found." >&2
	exit 1
fi

# Check if nitrogen is installed
if ! command -v nitrogen &>/dev/null; then
	echo "Error: Nitrogen is not installed. Please install it and try again." >&2
	exit 1
fi

# Set random wallpapers directly for all monitors
for wallpaper in {0..2}; do
	nitrogen --set-auto --random "$SOURCE_DIR" --head="$wallpaper" >/dev/null 2>&1
done
