#!/bin/bash

source "$(pwd)"/lib/common.sh
source "$(pwd)"/lib/script-functions.sh

source_path="$HOME/Pictures/nordic-wallpapers/wallpapers"
edge_path="$XDG_CONFIG_HOME/microsoft-edge/Default"
edge_bg_filepath="$edge_path/edge_background.jpg"

get_random_file (){
    [ ! -d "$source_path" ] && logger "$HOME/logs/edge_bg.log" "source dir not exist !!" && exit 1;

    file_path=$(find "$source_path"| shuf -n 1)
}

if [ -d "$edge_path" ] ;then
    if test -f "$edge_bg_filepath"; then
        logger_write "$HOME/.logs/edge_bg.log" "$edge_bg_filepath exists"

        get_random_file && cp -fr "$file_path" "$edge_bg_filepath"

        logger_write "$HOME/.logs/edge_bg.log" "Bg Change..."
    else
        logger_write "$HOME/.logs/edge_bg.log" "$edge_bg_filepath not exists"
    fi
else
    logger_write "$HOME/.logs/edge_bg.log" "Microsoft edge default path or source path incorrect"
fi
