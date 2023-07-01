#!/bin/bash

source "$(pwd)"/lib/script-functions.sh

config_core(){
    cd "config/$1" && pwd

    for file in *.json_bk; do
        cp -- "$file" "${file%.json_bk}.json"
    done;
}

config_other(){
    cp ".env.development.local_preconfig" ".env.$1.local"
}

source_install(){
    cd "$1" && pwd

    branch=$(git branch -r | cut -c 3- | gum choose)

    git checkout "$branch" && gum spin -s dot --title "Installing" -- npm i
}

check_packages_linux "gum"

gum style \
    --foreground 212 --border-foreground 212 --border double \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    'Welcom to source setup !! Clone and ready to use in couple second'

opts=$(gum choose "(1) Start" "(2) Cancel")

if [ "$opts" -eq 1 ]; then
    sources=$(gum choose --no-limit "backend-core" "billing" "admin-panel" )

    base_path=$HOME/Documents/$(gum input --placeholder "Append to base_path $HOME/Documents/....")

    [ -d "$base_path" ] || mkdir -p "$base_path"

    [ -n "$sources" ] &&
    for src in $sources; do

        app_env=$(gum input --placeholder "Set up for environment")

        gum confirm "Proceed cloning ??" && case "$src" in
            "backend-core")
                mkdir -p "$base_path/core-backend"

                gum spin -s line --title "Cloning..." -- git clone git@bitbucket.org:workgotcom/backend.git "$base_path/core-backend"

                source_install "$base_path/core-backend"

                config_core "$app_env"
                ;;
            "admin-panel")
                mkdir -p "$base_path/ap-backend"

                gum spin -s line --title "Cloning..." -- git clone git@bitbucket.org:workgotcom/ap-backend.git  "$base_path/ap-backend"

                source_install "$base_path/ap-backend"

                config_other "$app_env"
                ;;
            "billing")
                mkdir -p "$base_path/billing"

                gum spin -s line --title "Cloning..." -- git clone git@bitbucket.org:workgotcom/billing-backend.git "$base_path/billing-backend"

                source_install "$base_path/billing-backend"

                config_other "$app_env"
                ;;
        esac

    done
else
    echo "Exit..."
fi

echo "Your ready to go :heart: " | gum format -t emoji
