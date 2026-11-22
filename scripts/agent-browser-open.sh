#!/usr/bin/env bash
set -euo pipefail

# Open URLs in the agent Chrome through the browse relay. The systemd unit owns
# the browser process, so this script never launches a second Chrome: a second
# launcher makes Chrome forward the URL and exit, which confuses the unit and can
# take the browser down with it.

readonly BROWSE="$HOME/.local/bin/browse"

if [ "$#" -eq 0 ]; then
    printf 'usage: %s URL [URL...]\n' "$(basename "$0")" >&2
    exit 2
fi

"$HOME/dotfiles/scripts/agent-browser.sh"

for _ in $(seq 1 20); do
    if "$BROWSE" status --json 2>/dev/null | grep -q '"connected": *true'; then
        break
    fi
    sleep 1
done

for url in "$@"; do
    "$BROWSE" navigate "$url" >/dev/null
done
