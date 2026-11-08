#!/usr/bin/env bash
# Send the daily training message from JT-notes.
# The coach writes the message to a file. This script publishes that file, so
# the model never owns the side effect.
set -euo pipefail

readonly MODEL="opencode-go/deepseek-v4.1-flash"
readonly TIMEOUT_SECONDS=900
readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/workout-coach"
readonly LOG_FILE="$STATE_DIR/run.log"
readonly MESSAGE_FILE="$STATE_DIR/message.txt"
readonly CONFIG="$HOME/.config/opencode/ntfy.json"

TODAY="$(date +%F)"
readonly TODAY

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

log() {
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >>"$LOG_FILE"
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

notes_dir="$(find_notes_dir)" || {
  log "FAILED: JT-notes not found"
  exit 1
}
readonly NOTES_DIR="$notes_dir"
readonly ROUTINE="$NOTES_DIR/routines/workout-coach.md"

TOPIC="$(jq -r '.routineTopic // "routine"' "$CONFIG" 2>/dev/null || printf 'routine')"
readonly TOPIC
readonly SENT_FILE="$STATE_DIR/last-sent"

fail() {
  log "FAILED: $*"
  printf 'Workout coach failed at %s. Check the log on knockon.\n' "$(date +%H:%M)" |
    ntfy publish --title "Workout coach failed" "$TOPIC" >/dev/null 2>&1 || true
  exit 1
}

if [[ "${1:-}" != "--force" && -f "$SENT_FILE" && "$(cat "$SENT_FILE")" == "$TODAY" ]]; then
  log "already sent for $TODAY; skip"
  exit 0
fi

[[ -f "$ROUTINE" ]] || fail "routine file missing: $ROUTINE"
command -v jq >/dev/null || fail "jq not found"
command -v ntfy >/dev/null || fail "ntfy not found"

rm -f "$MESSAGE_FILE"

prompt="Write today's training message to $MESSAGE_FILE.

$(cat "$ROUTINE")"

runner=(opencode run --model "$MODEL" --auto --title "Workout coach $TODAY")
if command -v timeout >/dev/null; then
  runner=(timeout "$TIMEOUT_SECONDS" "${runner[@]}")
fi

log "start $TODAY"
if ! "${runner[@]}" "$prompt" >>"$LOG_FILE" 2>&1; then
  fail "opencode run returned non-zero"
fi

[[ -s "$MESSAGE_FILE" ]] || fail "the coach wrote no message"

message="$(sed -e 's/[[:space:]]*$//' "$MESSAGE_FILE" | sed -e '/./,$!d')"

if [[ -z "${message//[[:space:]]/}" ]]; then
  fail "the message file is empty"
fi

if ! printf '%s\n' "$message" | ntfy publish --title "Workout coach" "$TOPIC" >>"$LOG_FILE" 2>&1; then
  fail "ntfy publish failed"
fi

printf '%s\n' "$TODAY" >"$SENT_FILE"
log "sent $TODAY: ${#message} bytes"
