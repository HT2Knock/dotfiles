#!/bin/bash

SOURCE_DIR="/home/cubable-be-4/Pictures/walls"

category_path="$(find $SOURCE_DIR -maxdepth 1 -type d -not -name "animated" -and -not -name ".*" | shuf -n 1)"

wall_paper=$(find "$category_path" -not -name "*.md" -and -not -name ".*" | shuf -n 1)

feh "$wall_paper" --bg-scale
