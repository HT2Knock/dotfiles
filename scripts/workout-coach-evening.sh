#!/usr/bin/env bash
# Nudge the user to log the day's session.
# Fires only when the morning coach ran and the log has no entry for today.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
# shellcheck source=lib/workout-coach-common.sh
source "$SCRIPT_DIR/lib/workout-coach-common.sh"

readonly LOG_FILE="$STATE_DIR/evening.log"
readonly MORNING_SENT="$STATE_DIR/last-sent"
readonly EVENING_SENT="$STATE_DIR/evening-sent"

TODAY="$(date +%F)"
readonly TODAY

init_state

notes_dir="$(find_notes_dir)" || {
  log "FAILED: JT-notes not found"
  exit 1
}
readonly NOTES_DIR="$notes_dir"
readonly WORKOUT_LOG="${WORKOUT_LOG:-$NOTES_DIR/personal/workout_log.md}"

TOPIC="$(read_topic)"
readonly TOPIC

if [[ "${1:-}" != "--force" && -f "$EVENING_SENT" && "$(cat "$EVENING_SENT")" == "$TODAY" ]]; then
  log "already sent for $TODAY; skip"
  exit 0
fi

if [[ "${1:-}" != "--force" ]] && ! within_hours 20 22; then
  log "outside 20:00-22:00; skip"
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
  newest="$(grep -oE '^## [0-9]{4}-[0-9]{2}-[0-9]{2}' "$WORKOUT_LOG" | cut -d' ' -f2 | sort | tail -1)"
  if [[ -n "$newest" ]]; then
    open=()
    more=""
    for i in 1 2 3 4 5 6 7 8; do
      day="$(date -d "$newest + $i day" +%F 2>/dev/null)" || break
      [[ "$day" < "$TODAY" ]] || break
      if ((${#open[@]} < 7)); then
        open+=("$day")
      else
        more=", and more"
        break
      fi
    done
    if ((${#open[@]} > 0)); then
      joined="$(printf '%s, ' "${open[@]}")"
      message+=$'\n\n'"Open since the last entry ($newest): ${joined%, }${more}."
    fi
  fi
fi

if ! printf '%s\n' "$message" | ntfy publish --title "Log the session" "$TOPIC" >>"$LOG_FILE" 2>&1; then
  log "FAILED: ntfy publish failed"
  exit 1
fi

printf '%s\n' "$TODAY" >"$EVENING_SENT"
log "sent $TODAY"
