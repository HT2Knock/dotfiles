#!/usr/bin/env bash
# Send the daily training message from JT-notes.
# The coach writes the message to a file. This script publishes that file, so
# the model never owns the side effect.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
# shellcheck source=lib/workout-coach-common.sh
source "$SCRIPT_DIR/lib/workout-coach-common.sh"

readonly MODEL="opencode-go/deepseek-v4.1-flash"
readonly TIMEOUT_SECONDS=900
readonly LOG_FILE="$STATE_DIR/run.log"
readonly RUN_JSON="$STATE_DIR/run.jsonl"
readonly MESSAGE_FILE="$STATE_DIR/message.txt"
readonly SESSION_FILE="$STATE_DIR/last-session"

TODAY="$(date +%F)"
readonly TODAY

TEST=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --test) TEST=1 ;;
    --force) FORCE=1 ;;
  esac
done
readonly TEST FORCE

if ((TEST)); then
  TITLE="[TEST] Workout coach · $(LC_ALL=C date +'%-d %b')"
else
  TITLE="Workout coach · $(LC_ALL=C date +'%-d %b')"
fi
readonly TITLE

init_state

notes_dir="$(find_notes_dir)" || {
  log "FAILED: JT-notes not found"
  exit 1
}
readonly NOTES_DIR="$notes_dir"
readonly ROUTINE="$NOTES_DIR/routines/workout-coach.md"

TOPIC="$(read_topic)"
readonly TOPIC
readonly SENT_FILE="$STATE_DIR/last-sent"

fail() {
  log "FAILED: $*"
  printf 'Workout coach failed at %s. Check the log on knockon.\n' "$(date +%H:%M)" |
    ntfy publish --title "Workout coach failed" --priority high --tags warning "$TOPIC" >/dev/null 2>&1 || true
  exit 1
}

if ((TEST == 0 && FORCE == 0)) && [[ -f "$SENT_FILE" && "$(cat "$SENT_FILE")" == "$TODAY" ]]; then
  log "already sent for $TODAY; skip"
  exit 0
fi

if ((TEST == 0 && FORCE == 0)) && ! within_hours 5 10; then
  log "outside 5:00-10:00; skip"
  exit 0
fi

[[ -f "$ROUTINE" ]] || fail "routine file missing: $ROUTINE"
command -v jq >/dev/null || fail "jq not found"
command -v ntfy >/dev/null || fail "ntfy not found"

# Create the notes the user fills by hand: last night's block and today's page.
# A file that exists is never touched, and git trouble never blocks the message.
ensure_daily_notes() {
  local created path
  created="$(python3 "$NOTES_DIR/scripts/daily-note.py" --ensure yesterday --ensure today 2>>"$LOG_FILE")" ||
    { log "daily notes: ensure failed"; return 0; }
  [[ -n "$created" ]] || return 0
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    git -C "$NOTES_DIR" add -- "$path"
  done <<<"$created"
  git -C "$NOTES_DIR" diff --cached --quiet || {
    git -C "$NOTES_DIR" commit -q -m "note: create the daily notes for $TODAY" || log "daily notes: commit failed"
  }
  if git -C "$NOTES_DIR" push -q origin HEAD 2>>"$LOG_FILE"; then
    log "daily notes: created $(tr '\n' ' ' <<<"$created")"
    return 0
  fi
  git -C "$NOTES_DIR" pull --rebase --autostash -q 2>>"$LOG_FILE" &&
    git -C "$NOTES_DIR" push -q origin HEAD 2>>"$LOG_FILE" && {
      log "daily notes: created $(tr '\n' ' ' <<<"$created")"
      return 0
    }
  log "daily notes: created $(tr '\n' ' ' <<<"$created"), push failed"
}
ensure_daily_notes

rm -f "$MESSAGE_FILE" "$RUN_JSON"

prompt="Write today's training message to $MESSAGE_FILE.

$(cat "$ROUTINE")"

runner=(opencode run --model "$MODEL" --title "Workout coach $TODAY" --format json)
if command -v timeout >/dev/null; then
  runner=(timeout "$TIMEOUT_SECONDS" "${runner[@]}")
fi

log "start $TODAY"
if ! "${runner[@]}" "$prompt" >"$RUN_JSON" 2>>"$LOG_FILE"; then
  fail "opencode run returned non-zero"
fi

[[ -s "$MESSAGE_FILE" ]] || fail "the coach wrote no message"

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

message+=$'\n\n'"Fill last night: dailies/$(date -d yesterday +%F).md"

if ! publish_routine "$TITLE" muscle "$message" "$link" low >>"$LOG_FILE" 2>&1; then
  fail "ntfy publish failed"
fi

if [[ -n "$session_id" ]]; then
  printf '%s\n' "$session_id" >"$SESSION_FILE"
fi
if ((TEST == 0)); then
  printf '%s\n' "$TODAY" >"$SENT_FILE"
fi
log "sent $TODAY: ${#message} bytes, session=${session_id:-none}, link=$([[ -n "$link" ]] && printf yes || printf no)"
