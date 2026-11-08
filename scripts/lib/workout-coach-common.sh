#!/usr/bin/env bash
# Shared helpers for the workout coach runners. Source this file.

readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/workout-coach"
readonly CONFIG="$HOME/.config/opencode/ntfy.json"

log() {
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >>"${LOG_FILE:?LOG_FILE is not set}"
}

find_notes_dir() {
  local candidate
  for candidate in "$HOME/JT-notes" "$HOME/Documents/T2Knock/JT-notes"; do
    if [[ -d "$candidate/routines" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

init_state() {
  mkdir -p "$STATE_DIR"
  chmod 700 "$STATE_DIR"
}

read_topic() {
  jq -r '.routineTopic // "routine"' "$CONFIG" 2>/dev/null || printf 'routine'
}

within_hours() {
  local start="$1" end="$2" hour
  hour="$(date +%-H)"
  ((hour >= start && hour < end))
}
