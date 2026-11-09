#!/usr/bin/env bash
# Shared helpers for the workout coach runners. Source this file.

readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/${STATE_NAME:-workout-coach}"
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

# Print the public HTTPS origin of the local OpenCode server, or nothing.
public_origin() {
  opencode api get /api/info 2>/dev/null |
    jq -r '.urls[]? | select(startswith("https://"))' 2>/dev/null |
    head -n 1 || true
}

# Build the web URL for a session.
session_url() {
  local origin="$1" session_id="$2" key
  key="$(printf '%s' "$origin" | base64 | tr -d '\n' | tr '+/' '-_' | tr -d '=')"
  printf '%s/server/%s/session/%s\n' "$origin" "$key" "$session_id"
}

# Wrap a URL in the Reynard deep link.
reynard_url() {
  local url="$1"
  printf 'reynard://open?url=%s\n' "$(printf '%s' "$url" | jq -sRr @uri)"
}

# Publish a routine message. Appends the session footer when a link exists.
publish_routine() {
  local title="$1" tags="$2" message="$3" link="$4"
  local args=(--title "$title" --tags "$tags")
  if [[ -n "$link" ]]; then
    args+=(--click "$link" --actions "view, Open session, $link, clear=true")
    message+=$'\n\n'"Tap to open today's session in Reynard."
  fi
  printf '%s\n' "$message" | ntfy publish "${args[@]}" "$TOPIC"
}
