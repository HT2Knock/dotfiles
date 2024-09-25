#!/bin/bash

SOURCE_DIR="$HOME/Pictures/aesthetic-wallpapers/images"

# Check if SOURCE_DIR exists
if [ ! -d "$SOURCE_DIR" ]; then
	echo "Error: Source directory $SOURCE_DIR not found." >&2
	exit 1
fi

# Select and set a random image as background
img_name=$(fd -t f -e png -e jpg -e jpeg . "$SOURCE_DIR" | shuf -n 1)

# Check if an image was found
if [ -z "$img_name" ]; then
	echo "Error: No image files found in $SOURCE_DIR." >&2
	exit 1
fi

# Set desktop background
feh --bg-fill "$img_name"
