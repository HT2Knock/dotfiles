#!/bin/bash

SOURCE_DIR="$HOME/Pictures/aesthetic-wallpapers/images"

# Check if SOURCE_DIR exists
if [ ! -d "$SOURCE_DIR" ]; then
	echo "Error: Source directory $SOURCE_DIR not found." >&2
	exit 1
fi

# Seed the random generator using high-precision time for better randomness
RANDOM=$(od -vAn -N4 -tu4 </dev/urandom)

# Find all valid image files (png, jpg, jpeg) and shuffle the list
img_name=$(fd -t f -e png -e jpg -e jpeg . "$SOURCE_DIR" | sort -R | head -n 1)

# Check if an image was found
if [ -z "$img_name" ]; then
	echo "Error: No image files found in $SOURCE_DIR." >&2
	exit 1
fi

# Set desktop background using feh
feh --bg-scale "$img_name"
