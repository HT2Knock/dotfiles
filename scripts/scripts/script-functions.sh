#!/bin/bash

function install_gum_linux(){
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
    sudo apt update && sudo apt install gum
}


function check_packages_linux(){
    package="$(dpkg-query -W --showformat='${Status}\n' "$1" | grep "ok installed")"

    echo Checking for "$1": "$package"
    if [ -z "$package" ]; then
        echo "No $1. Setting up $1."

        install_"$1"_linux
    fi
}
