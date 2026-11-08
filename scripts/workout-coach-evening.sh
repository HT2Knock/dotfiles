#!/usr/bin/env bash
# Nudge the user to log the day's session.
# Fires only when the morning coach ran and the log has no entry for today.
set -euo pipefail

readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/workout-coach"
readonly LOG_FILE="$STATE_DIR/evening.log"
readonly MORNING_SENT="$STATE_DIR/last-sent"
readonly EVENING_SENT="$STATE_DIR/evening-sent"
readonly CONFIG="$HOME/.config/opencode/ntfy.json"

TODAY="$(date +%F)"
readonly TODAY

readonly START_HOUR=20
readonly END_HOUR=22

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
readonly WORKOUT_LOG="${WORKOUT_LOG:-$NOTES_DIR/personal/workout_log.md}"

TOPIC="$(jq -r '.routineTopic // "routine"' "$CONFIG" 2>/dev/null || printf 'routine')"
readonly TOPIC

if [[ "${1:-}" != "--force" && -f "$EVENING_SENT" && "$(cat "$EVENING_SENT")" == "$TODAY" ]]; then
  log "already sent for $TODAY; skip"
  exit 0
fi

now_hour="$(date +%-H)"
if [[ "${1:-}" != "--force" ]] && ((now_hour < START_HOUR || now_hour >= END_HOUR)); then
  log "outside ${START_HOUR}:00-${END_HOUR}:00; skip"
  exit 0
fi

if [[ ! -f "$MORNING_SENT" || "$(cat "$MORNING_SENT")" != "$TODAY" ]]; then
  log "no morning message for $TODAY; skip"
  exit 0
fi

if [[ ! -f "$WORKOUT_LOG" ]]; then
  log "log missing: $WORKOUT_LOG; skip"
  exit 0
fi

if grep -qE "^## ${TODAY}( |$)" "$WORKOUT_LOG"; then
  log "already logged for $TODAY; skip"
  exit 0
fi

message="No session logged today.

If you trained, reply in today's Workout coach session with distance or sets, effort, and pain. A rest day needs no entry."

if [[ "$(date +%u)" == "7" ]]; then
  newest="$(grep -oE '^## [0-9]{4}-[0-9]{2}-[0-9]{2}' "$WORKOUT_LOG" | head -1 | cut -d' ' -f2)"
  if [[ -n "$newest" ]]; then
    open=()
    for i in 1 2 3 4 5 6 7; do
      day="$(date -d "$newest + $i day" +%F 2>/dev/null)" || break
      [[ "$day" < "$TODAY" ]] || break
      open+=("$day")
    done
    if ((${#open[@]} > 0)); then
      joined="$(printf '%s, ' "${open[@]}")"
      message+=$'\n\n'"Open since the last entry ($newest): ${joined%, }."
    fi
  fi
fi

if ! printf '%s\n' "$message" | ntfy publish --title "Log the session" "$TOPIC" >>"$LOG_FILE" 2>&1; then
  log "FAILED: ntfy publish failed"
  exit 1
fi

printf '%s\n' "$TODAY" >"$EVENING_SENT"
log "sent $TODAY"
