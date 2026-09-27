#!/usr/bin/env bash
set -euo pipefail

# Write the current explicit packages to the package lists in this repository.
#
# The lists are the source of truth for the declared system. This script is a
# bootstrap and refresh helper. It overwrites both lists. Review the result with
# 'git diff' before you commit.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly OUT_DIR="$REPO_DIR/packages"

mkdir -p "$OUT_DIR"

{
    echo "# Explicitly installed repository packages."
    echo "# Source of truth for 'scripts/install-packages.sh'. Edit by hand."
    echo "# Refresh from the live system with 'scripts/export-packages.sh'."
    pacman -Qqen | sort
} >"$OUT_DIR/repo.txt"

{
    echo "# Explicitly installed foreign and AUR packages."
    echo "# Source of truth for 'scripts/install-packages.sh'. Edit by hand."
    echo "# Refresh from the live system with 'scripts/export-packages.sh'."
    pacman -Qqem | sort
} >"$OUT_DIR/aur.txt"

echo "Wrote $OUT_DIR/repo.txt and $OUT_DIR/aur.txt"
