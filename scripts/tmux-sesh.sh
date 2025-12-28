#!/usr/bin/env bash

set -euo pipefail

session_list=$(sesh list --icons)

if [[ -z "$session_list" ]]; then
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
