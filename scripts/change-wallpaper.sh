#!/bin/bash

SOURCE_DIR="$HOME/Pictures/aesthetic-wallpapers/images"

pushd "$SOURCE_DIR" >/dev/null || exit 1

category_dir="$(find "${SOURCE_DIR}" -type -f | shuf -n 1)"

pushd "$category_dir" >/dev/null || exit 1

img_name=$(ls *.{png,jpg,jpeg} | shuf -n 1)

feh --bg-fill "${img_name}"
