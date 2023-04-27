#!/bin/bash

# Before cleaning
df -Th | sort

# Remove apt / apt-get files
sudo apt clean
sudo apt -s clean
sudo apt clean all
sudo apt autoremove
sudo apt-get clean
sudo apt-get -s clean
sudo apt-get clean all
sudo apt-get autoclean

#Remove Old Log Files
sudo rm -f /var/log/*gz

# Remove Thumbnail Cache
rm -rf ~/.cache/thumbnails/*

# Remove old snaps
snap list --all | awk '/disabled/{print $1, $3}' |

if [ "$(dpkg-query -W --showformat='${Status}\n' snap | grep -c 'ok installed')" -ne 0 ]; then
    while read -r snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done
fi

# After cleaning
df -Th | sort
