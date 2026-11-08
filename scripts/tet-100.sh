#!/usr/bin/env bash
# Send the TET100 message from JT-notes.
# The agent writes the message to a file. This script publishes that file, so
# the model never owns the side effect.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

STATE_NAME=tet-100
# shellcheck source=lib/workout-coach-common.sh
source "$SCRIPT_DIR/lib/workout-coach-common.sh"

readonly MODEL="opencode-go/deepseek-v4.1-flash"
readonly TIMEOUT_SECONDS=900
readonly LOG_FILE="$STATE_DIR/run.log"
readonly MESSAGE_FILE="$STATE_DIR/message.txt"
readonly FIRST_DAY="2026-11-09"
readonly LAST_DAY="2027-02-16"

TODAY="$(date +%F)"
readonly TODAY

init_state

if [[ "$TODAY" < "$FIRST_DAY" || "$TODAY" > "$LAST_DAY" ]]; then
  log "outside the 100 days ($FIRST_DAY to $LAST_DAY); skip"
  exit 0
fi

notes_dir="$(find_notes_dir)" || {
  log "FAILED: JT-notes not found"
  exit 1
}
readonly NOTES_DIR="$notes_dir"

if [[ "$(date +%u)" == "7" ]]; then
  readonly ROUTINE="$NOTES_DIR/routines/tet-100-sunday.md"
else
  readonly ROUTINE="$NOTES_DIR/routines/tet-100-daily.md"
fi
readonly TITLE="TET100 $TODAY"

TOPIC="$(read_topic)"
readonly TOPIC
readonly SENT_FILE="$STATE_DIR/last-sent"

fail() {
  log "FAILED: $*"
  printf 'TET100 failed at %s. Check the log on knockon.\n' "$(date +%H:%M)" |
    ntfy publish --title "TET100 failed" "$TOPIC" >/dev/null 2>&1 || true
  exit 1
}

if [[ "${1:-}" != "--force" && -f "$SENT_FILE" && "$(cat "$SENT_FILE")" == "$TODAY" ]]; then
  log "already sent for $TODAY; skip"
  exit 0
fi

if [[ "${1:-}" != "--force" ]] && ! within_hours 21 23; then
  log "outside 21:00-23:00; skip"
  exit 0
fi

[[ -f "$ROUTINE" ]] || fail "routine file missing: $ROUTINE"
command -v jq >/dev/null || fail "jq not found"
command -v ntfy >/dev/null || fail "ntfy not found"

rm -f "$MESSAGE_FILE"

prompt="Write today's TET100 message to $MESSAGE_FILE.

The log is $NOTES_DIR/personal/tet_100_log.md.

$(cat "$ROUTINE")"

runner=(opencode run --model "$MODEL" --title "$TITLE")
if command -v timeout >/dev/null; then
  runner=(timeout "$TIMEOUT_SECONDS" "${runner[@]}")
fi

log "start $TODAY ($ROUTINE)"
if ! "${runner[@]}" "$prompt" >>"$LOG_FILE" 2>&1; then
  fail "opencode run returned non-zero"
fi

[[ -s "$MESSAGE_FILE" ]] || fail "the agent wrote no message"

message="$(sed -e 's/[[:space:]]*$//' "$MESSAGE_FILE" | sed -e '/./,$!d')"

if [[ -z "${message//[[:space:]]/}" ]]; then
  fail "the message file is empty"
fi

if ! printf '%s\n' "$message" | ntfy publish --title "TET100" "$TOPIC" >>"$LOG_FILE" 2>&1; then
  fail "ntfy publish failed"
fi

printf '%s\n' "$TODAY" >"$SENT_FILE"
log "sent $TODAY: ${#message} bytes"
