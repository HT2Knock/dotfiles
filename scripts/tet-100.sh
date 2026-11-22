#!/usr/bin/env bash
# Send the 21:00 cue with a Yes and a No button. No model runs on this path.
#
# The cue text comes from scripts/tet100_stats.py in JT-notes, so the wave, the
# practice, and the active if-then have one source. A tap calls the answer
# server, which writes the nightly block and commits it.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

STATE_NAME=tet-100
# shellcheck source=lib/workout-coach-common.sh
source "$SCRIPT_DIR/lib/workout-coach-common.sh"

readonly LOG_FILE="$STATE_DIR/run.log"
readonly SENT_FILE="$STATE_DIR/last-sent"
readonly FIRST_DAY="2026-11-09"
readonly LAST_DAY="2027-02-16"
readonly ANSWER_BASE="https://knockon.turkey-alhena.ts.net/answer"

TODAY="$(date +%F)"
readonly TODAY
TITLE="TET100 · $(LC_ALL=C date +'%-d %b')"
readonly TITLE

TEST=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --test) TEST=1 ;;
    --force) FORCE=1 ;;
  esac
done
readonly TEST FORCE

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

fail() {
  log "FAILED: $*"
  printf 'TET100 cue failed at %s. Check the log on knockon.\n' "$(date +%H:%M)" |
    ntfy publish --title "TET100 failed" --priority high --tags warning "$TOPIC" >/dev/null 2>&1 || true
  exit 1
}

if ((TEST == 0 && FORCE == 0)) && [[ -f "$SENT_FILE" && "$(cat "$SENT_FILE")" == "$TODAY" ]]; then
  log "already sent for $TODAY; skip"
  exit 0
fi

if ((TEST == 0 && FORCE == 0)) && ! within_hours 21 23; then
  log "outside 21:00-23:00; skip"
  exit 0
fi

command -v ntfy >/dev/null || fail "ntfy not found"
command -v python3 >/dev/null || fail "python3 not found"

TOPIC="$(read_topic)"
readonly TOPIC

message="$(python3 "$NOTES_DIR/scripts/tet100_stats.py" --cue --date "$TODAY")" ||
  fail "the cue script failed"
[[ -n "$message" ]] || fail "the cue is empty"

if ((TEST)); then
  printf '%s\n' "$message" |
    ntfy publish --title "[TEST] $TITLE" --tags bed --priority low "$TOPIC" >>"$LOG_FILE" 2>&1 ||
    fail "test publish failed"
  log "test cue sent $TODAY"
  exit 0
fi

token="$(python3 "$NOTES_DIR/scripts/answer-server.py" --token "$TODAY")" ||
  fail "the token script failed"
[[ -n "$token" ]] || fail "the token is empty"

actions="http, Yes, $ANSWER_BASE?d=$TODAY&v=yes&t=$token, method=GET"
actions+="; http, No, $ANSWER_BASE?d=$TODAY&v=no&t=$token, method=GET"

if ! printf '%s\n' "$message" |
  ntfy publish --title "$TITLE" --tags bed --priority low --actions "$actions" "$TOPIC" >>"$LOG_FILE" 2>&1; then
  fail "publish failed"
fi

printf '%s\n' "$TODAY" >"$SENT_FILE"
log "cue sent $TODAY: ${#message} bytes, buttons=yes,no"
