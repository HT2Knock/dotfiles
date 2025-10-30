#!/usr/bin/env bash

set -euo pipefail

if ! sesh list --icons | grep -q .; then
    echo "No sessions available" >&2
    exit 0
fi

selection=$(
    sesh list --icons | fzf-tmux -p 80%,70% \
        --border-label " ⚡sesh "
) || true

if [[ -n "$selection" ]]; then
    sesh connect "$selection"
fi
