#!/usr/bin/env bash
# Log fan speed, PWM level, and temperatures. Used to catch an intermittent
# fan ramp. Uses bash builtins only, so a sample costs about a millisecond.

set -euo pipefail

readonly LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/fan-watch"
readonly LOG_FILE="$LOG_DIR/fan.log"
readonly MAX_BYTES=$((5 * 1024 * 1024))
readonly INTERVAL=30

hwmon_dir() {
	local want=$1 dir value
	for dir in /sys/class/hwmon/hwmon*; do
		[[ -r "$dir/name" ]] || continue
		value=
		read -r value <"$dir/name" 2>/dev/null || true
		if [[ "$value" == "$want" ]]; then
			printf '%s\n' "$dir"
			return 0
		fi
	done
	return 1
}

read_value() {
	local value=
	read -r value <"$1" 2>/dev/null || true
	printf '%s' "$value"
}

celsius() {
	local value
	value=$(read_value "$1")
	if [[ "$value" =~ ^-?[0-9]+$ ]]; then
		printf '%d' $((value / 1000))
	else
		printf 'na'
	fi
}

mkdir -p "$LOG_DIR"
if [[ -f "$LOG_FILE" ]] && (($(stat -c %s "$LOG_FILE") > MAX_BYTES)); then
	mv -f "$LOG_FILE" "$LOG_FILE.1"
fi

while true; do
	smm=$(hwmon_dir dell_smm) || smm=/nonexistent
	core=$(hwmon_dir coretemp) || core=/nonexistent
	load=
	read -r load _ </proc/loadavg || true

	printf '%(%Y-%m-%dT%H:%M:%S%z)T fan=%s pwm=%s cpu=%s ambient=%s gpu=%s load=%s\n' \
		-1 \
		"$(read_value "$smm/fan1_input")" \
		"$(read_value "$smm/pwm1")" \
		"$(celsius "$core/temp1_input")" \
		"$(celsius "$smm/temp1_input")" \
		"$(celsius "$smm/temp3_input")" \
		"$load" >>"$LOG_FILE"

	sleep "$INTERVAL"
done
