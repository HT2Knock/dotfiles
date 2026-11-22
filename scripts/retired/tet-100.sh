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
readonly RUN_JSON="$STATE_DIR/run.jsonl"
readonly MESSAGE_FILE="$STATE_DIR/message.txt"
readonly SESSION_FILE="$STATE_DIR/last-session"
readonly FIRST_DAY="2026-11-09"
readonly LAST_DAY="2027-02-16"

TODAY="$(date +%F)"
readonly TODAY

TEST=0
CHASE=0
for arg in "$@"; do
  case "$arg" in
    --test) TEST=1 ;;
    --chase) CHASE=1 ;;
  esac
done
readonly TEST CHASE

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
if ((TEST)); then
  SESSION_TITLE="[TEST] TET100 $TODAY"
  NOTIFY_TITLE="[TEST] TET100 · $(LC_ALL=C date +'%-d %b')"
else
  SESSION_TITLE="TET100 $TODAY"
  NOTIFY_TITLE="TET100 · $(LC_ALL=C date +'%-d %b')"
fi
readonly SESSION_TITLE NOTIFY_TITLE

TOPIC="$(read_topic)"
readonly TOPIC
readonly SENT_FILE="$STATE_DIR/last-sent"

fail() {
  log "FAILED: $*"
  printf 'TET100 failed at %s. Check the log on knockon.\n' "$(date +%H:%M)" |
    ntfy publish --title "TET100 failed" --priority high --tags warning "$TOPIC" >/dev/null 2>&1 || true
  exit 1
}

# One fixed chase at 21:45. It sends only when the cue went out today, the log
# has no report for today, and the chase has not already gone out. No model.
run_chase() {
  local log_file="$NOTES_DIR/personal/tet_100_log.md"
  local chase_file="$STATE_DIR/last-chase"
  local session_file="$STATE_DIR/last-session"
  local block="" session_id="" origin="" link=""

  [[ -f "$log_file" ]] || fail "log missing: $log_file"

  if ((TEST == 0)); then
    if [[ ! -f "$SENT_FILE" || "$(cat "$SENT_FILE")" != "$TODAY" ]]; then
      log "chase: no cue for $TODAY; skip"
      return 0
    fi
    if [[ -f "$chase_file" && "$(cat "$chase_file")" == "$TODAY" ]]; then
      log "chase: already sent for $TODAY; skip"
      return 0
    fi
    if ! within_hours 21 23; then
      log "chase: outside 21:00-23:00; skip"
      return 0
    fi
  fi

  block="$(awk -v day="## $TODAY" '$0 == day {found=1; next} /^## / {found=0} found' "$log_file")"
  if grep -q '^Phone away:' <<<"$block"; then
    log "chase: $TODAY already reported; skip"
    return 0
  fi

  if [[ -f "$session_file" ]]; then
    session_id="$(cat "$session_file")"
    origin="$(public_origin || true)"
    if [[ -n "$origin" && -n "$session_id" ]]; then
      link="$(reynard_url "$(session_url "$origin" "$session_id")")"
    fi
  fi

  if ! publish_routine "$NOTIFY_TITLE" bed "Phone away? Reply yes or no." "$link" >>"$LOG_FILE" 2>&1; then
    fail "chase publish failed"
  fi
  ((TEST)) || printf '%s\n' "$TODAY" >"$chase_file"
  log "chase sent $TODAY: session=${session_id:-none}, test=$TEST"
  return 0
}

if ((CHASE)); then
  run_chase
  exit 0
fi

if ((TEST == 0)) && [[ "${1:-}" != "--force" && -f "$SENT_FILE" && "$(cat "$SENT_FILE")" == "$TODAY" ]]; then
  log "already sent for $TODAY; skip"
  exit 0
fi

if ((TEST == 0)) && [[ "${1:-}" != "--force" ]] && ! within_hours 21 23; then
  log "outside 21:00-23:00; skip"
  exit 0
fi

[[ -f "$ROUTINE" ]] || fail "routine file missing: $ROUTINE"
command -v jq >/dev/null || fail "jq not found"
command -v ntfy >/dev/null || fail "ntfy not found"

rm -f "$MESSAGE_FILE" "$RUN_JSON"

prompt="Write today's TET100 message to $MESSAGE_FILE.

The log is $NOTES_DIR/personal/tet_100_log.md.

$(cat "$ROUTINE")"

runner=(opencode run --model "$MODEL" --title "$SESSION_TITLE" --format json)
if command -v timeout >/dev/null; then
  runner=(timeout "$TIMEOUT_SECONDS" "${runner[@]}")
fi

log "start $TODAY ($ROUTINE)"
if ! "${runner[@]}" "$prompt" >"$RUN_JSON" 2>>"$LOG_FILE"; then
  fail "opencode run returned non-zero"
fi

[[ -s "$MESSAGE_FILE" ]] || fail "the agent wrote no message"

message="$(sed -e 's/[[:space:]]*$//' "$MESSAGE_FILE" | sed -e '/./,$!d')"

if [[ -z "${message//[[:space:]]/}" ]]; then
  fail "the message file is empty"
fi

session_id="$(head -n 1 "$RUN_JSON" 2>/dev/null | jq -r '.sessionID // empty' 2>/dev/null || true)"
origin="$(public_origin || true)"
link=""
if [[ -n "$session_id" && -n "$origin" ]]; then
  link="$(reynard_url "$(session_url "$origin" "$session_id")")"
fi

if ! publish_routine "$NOTIFY_TITLE" bed "$message" "$link" >>"$LOG_FILE" 2>&1; then
  fail "ntfy publish failed"
fi

if ((TEST == 0)); then
  printf '%s\n' "$TODAY" >"$SENT_FILE"
fi
if [[ -n "$session_id" ]]; then
  printf '%s\n' "$session_id" >"$SESSION_FILE"
fi
log "sent $TODAY: ${#message} bytes, session=${session_id:-none}, link=$([[ -n "$link" ]] && printf yes || printf no), test=$TEST"
