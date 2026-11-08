#!/usr/bin/env bash
# Send the daily workout session from JT-notes.
# The model writes the text. This script owns delivery: it extracts the text
# between the markers and publishes it to the routine topic.
set -euo pipefail

readonly MODEL="opencode-go/deepseek-v4.1-flash"
readonly TIMEOUT_SECONDS=900
readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/workout-coach"
readonly LOG_FILE="$STATE_DIR/run.log"
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

prompt="Today is $TODAY in Asia/Ho_Chi_Minh.

$(cat "$ROUTINE")"

runner=(opencode run --format json --model "$MODEL" --auto --archived --title "workout-coach $TODAY")
if command -v timeout >/dev/null; then
  runner=(timeout "$TIMEOUT_SECONDS" "${runner[@]}")
fi

log "start $TODAY"
if ! json="$("${runner[@]}" "$prompt" 2>>"$LOG_FILE")"; then
  fail "opencode run returned non-zero"
fi

text="$(printf '%s\n' "$json" | jq -r 'select(.type == "text") | .part.text' 2>/dev/null)" ||
  fail "could not read the JSON output"

message="$(printf '%s\n' "$text" | awk '
  /<<<NOTIFY/ { inside = 1; sub(/.*<<<NOTIFY[[:space:]]*/, ""); if (length($0) > 0) lines[++count] = $0; next }
  inside && /NOTIFY>>>/ { sub(/[[:space:]]*NOTIFY>>>.*/, ""); if (length($0) > 0) lines[++count] = $0; exit }
  inside { lines[++count] = $0 }
  END { for (i = 1; i <= count; i++) printf "%s%s", lines[i], (i < count ? "\n" : "") }
')"

if [[ -z "${message//[[:space:]]/}" ]]; then
  fail "no NOTIFY block in the reply"
fi

if ! printf '%s' "$message" | ntfy publish --title "Workout coach" "$TOPIC" >>"$LOG_FILE" 2>&1; then
  fail "ntfy publish failed"
fi

printf '%s\n' "$TODAY" >"$SENT_FILE"
log "sent $TODAY: ${#message} bytes"
