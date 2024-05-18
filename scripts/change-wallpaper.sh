#!/bin/bash

SOURCE_DIR="$HOME/Pictures/aesthetic-wallpapers/images"

# Check if SOURCE_DIR exists
if [ ! -d "$SOURCE_DIR" ]; then
	echo "Error: Source directory $SOURCE_DIR not found." >&2
	exit 1
fi

# Select a random image file
while IFS= read -r -d '' img_name; do
	# Set desktop background
	feh --bg-scale "$img_name"
	break # Exit after setting the background once
done < <(fd -0 -e png -e jpg -e jpeg . "/home/knock-huynh/Pictures/aesthetic-wallpapers/images" | shuf -zn 1)

# Check if img_name is empty
if [ "$img_name" = "" ]; then
	echo "Error: No image files found in $SOURCE_DIR." >&2
	exit 1
fi
