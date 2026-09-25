#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_NAME="display-mode"
readonly STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/$SCRIPT_NAME"
readonly MODE_FILE="$STATE_DIR/mode"
readonly DEFAULT_MODE="extend"
readonly LAPTOP_RE='^(eDP|LVDS|DSI|DPI)([-]?[0-9]+)?$'
readonly VIRTUAL_RE='^(HEADLESS|VIRTUAL|WL-|Xvfb)'

mkdir -p "$STATE_DIR"

log() { printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2; }
notify() { notify-send -a "$SCRIPT_NAME" "${@}" 2>/dev/null || true; }

laptop_output() {
	if [[ -n "${DISPLAY_MODE_LAPTOP:-}" ]]; then
		printf '%s' "$DISPLAY_MODE_LAPTOP"
		return
	fi
	hyprctl monitors all -j | jq -r --arg re "$LAPTOP_RE" \
		'.[] | select(.name | test($re; "i")) | .name' | head -n1
}

# `monitors all` includes disabled and mirrored outputs; `monitors` alone hides
# the mirroring output, so every check uses the full list.
all_monitors() { hyprctl monitors all -j; }

externals_all() {
	local laptop
	laptop="$(laptop_output)"
	all_monitors | jq -r --arg laptop "$laptop" --arg re "$VIRTUAL_RE" \
		'.[] | select(.name != $laptop) | select((.name | test($re; "i")) | not) | .name'
}

externals_in_use() {
	local laptop
	laptop="$(laptop_output)"
	all_monitors | jq -r --arg laptop "$laptop" --arg re "$VIRTUAL_RE" \
		'.[] | select(.name != $laptop) | select((.name | test($re; "i")) | not) | select(.disabled | not) | .name'
}

lid_state() {
	if [[ -n "${DISPLAY_MODE_LID_STATE:-}" ]]; then
		printf '%s' "$DISPLAY_MODE_LID_STATE"
		return
	fi
	if grep -qi closed /proc/acpi/button/lid/*/state 2>/dev/null; then
		printf 'closed'
	else
		printf 'open'
	fi
}

laptop_disabled() {
	local laptop disabled
	laptop="$(laptop_output)"
	[[ -z "$laptop" ]] && {
		printf 'true'
		return
	}
	disabled="$(all_monitors | jq -r --arg laptop "$laptop" '.[] | select(.name == $laptop) | .disabled' | head -n1)"
	if [[ "$disabled" == "false" ]]; then printf 'false'; else printf 'true'; fi
}

# Prints the external output that is mirroring the built-in panel, if any.
mirror_source() {
	local laptop
	laptop="$(laptop_output)"
	all_monitors | jq -r --arg laptop "$laptop" --arg re "$VIRTUAL_RE" \
		'.[] | select(.name != $laptop) | select((.name | test($re; "i")) | not) | select(.disabled | not)
		 | select(.mirrorOf != "none" and .mirrorOf != "") | .name' | head -n1
}

current_layout() {
	local ext lap_disabled
	ext="$(externals_in_use)"
	[[ -z "$ext" ]] && {
		printf 'builtin'
		return
	}
	if [[ -n "$(mirror_source)" ]]; then
		printf 'mirror'
		return
	fi
	lap_disabled="$(laptop_disabled)"
	if [[ "$lap_disabled" == "false" ]]; then printf 'extend'; else printf 'external'; fi
}

mode_label() {
	case "$1" in
	builtin) printf 'Built-in only' ;;
	external) printf 'External only (clamshell)' ;;
	mirror) printf 'Mirror' ;;
	extend) printf 'Extend' ;;
	*) printf '%s' "$1" ;;
	esac
}

mode_icon() {
	case "$1" in
	builtin) printf '\U000f0322' ;;
	external) printf '\U000f0379' ;;
	mirror) printf '\U000f06d6' ;;
	extend) printf '\U000f037a' ;;
	*) printf '\U000f0379' ;;
	esac
}

saved_mode() {
	local mode=""
	[[ -f "$MODE_FILE" ]] && mode="$(<"$MODE_FILE")"
	[[ -z "$mode" ]] && mode="$DEFAULT_MODE"
	printf '%s' "$mode"
}

# A monitor rule with a field omitted keeps that field's current runtime value,
# so every enabled rule states mode, position, scale, mirror, and disabled.
monitor_rule() {
	local name="$1" mode="$2" position="$3" mirror="$4"
	printf 'hl.monitor({ output = "%s", mode = "%s", position = "%s", scale = "auto", mirror = "%s", disabled = false });' \
		"$name" "$mode" "$position" "$mirror"
}

apply_layout() {
	local mode="$1" laptop primary ext code=""
	laptop="$(laptop_output)"
	if [[ -z "$laptop" ]]; then
		log "no built-in output found"
		return 1
	fi

	local -a externals=()
	while IFS= read -r ext; do
		[[ -n "$ext" ]] && externals+=("$ext")
	done < <(externals_all)
	primary="${externals[0]:-}"

	case "$mode" in
	builtin)
		for ext in "${externals[@]:-}"; do
			[[ -n "$ext" ]] && code+="hl.monitor({ output = \"$ext\", disabled = true });"
		done
		code+="$(monitor_rule "$laptop" preferred "0x0" none)"
		;;
	external)
		if [[ -z "$primary" ]]; then
			log "external mode requested but no external output is present"
			return 1
		fi
		code+="hl.monitor({ output = \"$laptop\", disabled = true });"
		for ext in "${externals[@]:-}"; do
			[[ -z "$ext" ]] && continue
			[[ "$ext" == "$primary" ]] && code+="$(monitor_rule "$ext" preferred "0x0" none)" || code+="$(monitor_rule "$ext" preferred auto none)"
		done
		;;
	extend)
		code+="$(monitor_rule "$laptop" preferred "0x0" none)"
		for ext in "${externals[@]:-}"; do
			[[ -n "$ext" ]] && code+="$(monitor_rule "$ext" preferred auto none)"
		done
		;;
	mirror)
		if [[ -z "$primary" ]]; then
			log "mirror mode requested but no external output is present"
			return 1
		fi
		# Two steps: the mirror target must exist when the mirror rule applies,
		# otherwise Hyprland silently falls back to an extended screen.
		hyprctl eval "$(monitor_rule "$laptop" preferred "0x0" none)" >/dev/null
		sleep 0.4
		for ext in "${externals[@]:-}"; do
			[[ -n "$ext" ]] && code+="$(monitor_rule "$ext" preferred auto "$laptop")"
		done
		hyprctl eval "$code" >/dev/null
		return 0
		;;
	*)
		log "unknown mode: $mode"
		return 2
		;;
	esac

	hyprctl eval "$code" >/dev/null
}

set_mode() {
	local mode="$1"
	case "$mode" in
	builtin | external | mirror | extend) ;;
	*)
		log "invalid mode: $mode"
		exit 2
		;;
	esac

	if [[ "$mode" != "builtin" && -z "$(externals_all)" ]]; then
		notify -u low "No external monitor" "Connect a monitor to use $(mode_label "$mode") mode."
		exit 1
	fi

	printf '%s\n' "$mode" >"$MODE_FILE"
	apply_layout "$mode"
	notify -u low "Display mode" "$(mode_label "$mode")"
}

lid_close() {
	if [[ -n "$(externals_in_use)" ]]; then
		apply_layout external
	fi
}

lid_open() {
	local mode
	mode="$(saved_mode)"
	if [[ -z "$(externals_all)" ]]; then
		mode="builtin"
	fi
	apply_layout "$mode"
}

recover() {
	local laptop ext lap_disabled lid saved
	laptop="$(laptop_output)"
	[[ -z "$laptop" ]] && return 0

	ext="$(externals_in_use)"
	lap_disabled="$(laptop_disabled)"

	# Bring the built-in panel back when the external monitor goes away.
	if [[ -z "$ext" ]]; then
		[[ "$lap_disabled" == "true" ]] && apply_layout builtin
		return 0
	fi

	lid="$(lid_state)"

	if [[ "$lid" == "closed" ]]; then
		[[ "$lap_disabled" != "true" ]] && apply_layout external
		return 0
	fi

	# Lid is open again: honor the last chosen mode.
	saved="$(saved_mode)"
	case "$saved" in
	external)
		[[ "$lap_disabled" != "true" ]] && apply_layout external
		;;
	extend | mirror)
		[[ "$lap_disabled" == "true" ]] && apply_layout "$saved"
		;;
	esac
}

toggle_mode() {
	if [[ -n "$(externals_in_use)" ]]; then
		if [[ "$(current_layout)" == "external" ]]; then
			set_mode extend
		else
			set_mode external
		fi
	else
		set_mode builtin
	fi
}

show_menu() {
	local current marker choice lines="" mode
	current="$(current_layout)"
	for mode in builtin extend external mirror; do
		if [[ "$mode" == "$current" ]]; then marker="●"; else marker=" "; fi
		lines+="$marker|$mode|$(mode_label "$mode")"$'\n'
	done

	choice="$(printf '%s' "$lines" | fuzzel --dmenu --prompt 'Display mode  ' --width 44 | cut -d'|' -f2)"
	[[ -z "$choice" ]] && return 0
	set_mode "$choice"
}

show_status() {
	local layout icon label lid tip monitors
	# Waybar polls this every couple of seconds, so it also reconciles state
	# in case the lid switch bind did not run.
	recover >/dev/null 2>&1 || true
	layout="$(current_layout)"
	icon="$(mode_icon "$layout")"
	label="$(mode_label "$layout")"
	lid="$(lid_state)"

	monitors="$(all_monitors | jq -r '.[] | select(.disabled | not)
		| "\(.name)\t\(.width)x\(.height)@\(.refreshRate | floor)Hz\(if (.mirrorOf != "none" and .mirrorOf != "") then " (mirror)" else "" end)"')"
	tip="$(printf '%s\n\n%s\n\nLid: %s\nLeft-click: choose mode\nRight-click: toggle built-in/external' \
		"$label" "$monitors" "$lid")"

	jq -c -n --arg text "$icon" --arg tooltip "$tip" --arg class "$layout" --arg alt "$layout" \
		'{text: $text, tooltip: $tooltip, class: $class, alt: $alt}'
}

case "${1:-status}" in
status) show_status ;;
menu) show_menu ;;
set) set_mode "${2:-}" ;;
toggle) toggle_mode ;;
lid-close) lid_close ;;
lid-open) lid_open ;;
recover | sync) recover ;;
*)
	log "usage: $(basename "$0") {status|menu|set <mode>|toggle|lid-close|lid-open|recover}"
	exit 2
	;;
esac
