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

# Get a random wallpaper file
WALLPAPER=$(find "$SOURCE_DIR" -type f | shuf -n 1)

# Set the same wallpaper for all monitors
for monitor in {0..1}; do
	nitrogen --set-auto "$WALLPAPER" --head="$monitor" >/dev/null 2>&1
done
