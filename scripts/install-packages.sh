#!/usr/bin/env bash
set -euo pipefail

# Install every package declared in packages/repo.txt and packages/aur.txt.
#
# The script runs a full upgrade first. A partial upgrade breaks an Arch system.
# Run it with a graphical session, so the sudo dialog can appear.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly REPO_LIST="$REPO_DIR/packages/repo.txt"
readonly AUR_LIST="$REPO_DIR/packages/aur.txt"

read_packages() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 0
    fi
    grep -vE '^[[:space:]]*(#|$)' "$file"
}

paru -Syu --needed

mapfile -t repo_packages < <(read_packages "$REPO_LIST")
mapfile -t aur_packages < <(read_packages "$AUR_LIST")
packages=("${repo_packages[@]}" "${aur_packages[@]}")

if [ "${#packages[@]}" -eq 0 ]; then
    echo "No packages declared in $REPO_DIR/packages"
    exit 0
fi

paru -S --needed "${packages[@]}"
