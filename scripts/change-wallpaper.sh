#!/bin/bash

SOURCE_DIR="$HOME/Pictures/walle/images"

# Check if SOURCE_DIR exists
if [ ! -d "$SOURCE_DIR" ]; then
	echo "Error: Source directory $SOURCE_DIR not found." >&2
	exit 1
fi

# Find all valid image files (png, jpg, jpeg) and store them in an array
mapfile -t images < <(find "$SOURCE_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \))

# Check if any images are found
if [ ${#images[@]} -eq 0 ]; then
	echo "Error: No image files found in $SOURCE_DIR." >&2
	exit 1
fi

# Select two random images
img1=${images[RANDOM % ${#images[@]}]}
img2=${images[RANDOM % ${#images[@]}]}

# Ensure different images are chosen for each monitor
while [ "$img2" == "$img1" ]; do
	img2=${images[RANDOM % ${#images[@]}]}
done

# Set wallpapers for dual monitors
feh --bg-fill "$img1" "$img2"
