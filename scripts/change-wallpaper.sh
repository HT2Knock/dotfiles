#!/bin/bash

SOURCE_DIR="/home/cubable-be-4/Pictures/walls"

pushd "$SOURCE_DIR" >/dev/null || exit 1

category_dir="$(ls | shuf -n 1)"

pushd "$category_dir" >/dev/null || exit 1

img_name=$(ls *.{png,jpg,jpeg} | shuf -n 1)

echo $img_name
