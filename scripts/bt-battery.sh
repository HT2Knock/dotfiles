#!/usr/bin/env bash
# Show battery and link health of Bluetooth input devices as Waybar JSON.
#
# BlueZ reports no RSSI for a classic HID keyboard, so a signal bar is not
# possible. The number of HID reconnects in the kernel log is the link-quality
# signal instead: a healthy link shows few reconnects, a weak link shows many.
#
# A Bluetooth input device reaches UPower in two forms:
#   /org/bluez/hci0/dev_XX  -> classic HID   (keyboard_dev_*)
#   hidpp_battery_N         -> Logitech HID++ (battery_hidpp_battery_N)
# Only devices whose address BlueZ knows are shown, so a USB Unifying receiver
# is not counted as Bluetooth.
#
# UPower lists a device only while it is connected. The last reading is cached,
# so a device that keeps dropping shows "last seen" instead of an empty module.
set -euo pipefail

readonly RECONNECT_WINDOW_MIN="${BT_BATTERY_WINDOW_MIN:-60}"
readonly UNSTABLE_DROPS="${BT_BATTERY_UNSTABLE_DROPS:-5}"
readonly CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/bt-battery/last"
readonly KEYBOARD_ICON="󰌌"
readonly MOUSE_ICON="󰍽"

battery_icon() {
    local pct="$1"
    if ((pct >= 90)); then echo "󰁹"
    elif ((pct >= 70)); then echo "󰂂"
    elif ((pct >= 50)); then echo "󰂀"
    elif ((pct >= 30)); then echo "󰁾"
    elif ((pct >= 10)); then echo "󰁻"
    else echo "󰂃"
    fi
}

battery_class() {
    local pct="$1"
    if ((pct <= 10)); then echo "critical"
    elif ((pct <= 20)); then echo "warning"
    else echo "good"
    fi
}

# Count HID reconnects in this boot's kernel log.
reconnect_count() {
    journalctl -k --since "${RECONNECT_WINDOW_MIN} min ago" --no-pager 2>/dev/null \
        | grep -Fc "BLUETOOTH HID" 2>/dev/null || echo 0
}

json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

# Read one "key: value" line from an upower -i block. The value may hold colons.
upower_field() {
    sed -n "s/^ *$1:[[:space:]]*//p" <<<"$2" | head -n 1
}

# Set of Bluetooth addresses known to BlueZ, lowercased.
bt_addresses() {
    local _ mac _
    while read -r _ mac _; do
        [ -n "$mac" ] && printf '%s\n' "${mac,,}"
    done < <(bluetoothctl devices 2>/dev/null || true)
}

relative_time() {
    local then="$1" now delta
    now="$(date +%s)"
    delta=$((now - then))
    if ((delta < 60)); then echo "${delta}s ago"
    elif ((delta < 3600)); then echo "$((delta / 60)) min ago"
    else echo "$((delta / 3600)) h ago"
    fi
}

prune_cache() {
    [ -f "$CACHE_FILE" ] || return 0
    tac "$CACHE_FILE" | awk -F'\t' '!seen[$1]++' | tac >"$CACHE_FILE.tmp"
    mv "$CACHE_FILE.tmp" "$CACHE_FILE"
}

main() {
    local -a text_parts=() tooltip_parts=() class_parts=()
    local unstable=0 have_connected=0
    local -A bt_mac=()
    local addr
    while IFS= read -r addr; do
        [ -n "$addr" ] && bt_mac["$addr"]=1
    done < <(bt_addresses)

    local path info model pct serial state kind icon drops
    mkdir -p "$(dirname "$CACHE_FILE")"
    : >"$CACHE_FILE.tmp"

    while IFS= read -r path; do
        [ -n "$path" ] || continue
        info="$(upower -i "$path" 2>/dev/null || true)"
        model="$(upower_field model "$info")"
        pct="$(upower_field percentage "$info")"
        pct="${pct%\%}"
        serial="$(upower_field serial "$info")"
        state="$(upower_field state "$info")"
        local serial_lc="${serial,,}"

        # Accept only a device that BlueZ knows, by address or by BlueZ path.
        if [[ -z "$serial_lc" || -z "${bt_mac[$serial_lc]:-}" ]]; then
            [[ "$path" == *"/org/bluez/"* ]] || continue
        fi

        have_connected=1
        case "$(awk '/^  (keyboard|mouse)$/ {print $1; exit}' <<<"$info")" in
            mouse) kind="Mouse"; icon="$MOUSE_ICON" ;;
            keyboard) kind="Keyboard"; icon="$KEYBOARD_ICON" ;;
            *) kind="Device"; icon="$KEYBOARD_ICON" ;;
        esac

        if [[ "$pct" =~ ^[0-9]+$ ]]; then
            drops="$(reconnect_count)"
            text_parts+=("$(battery_icon "$pct") $pct%")
            class_parts+=("$(battery_class "$pct")")
            if ((drops >= UNSTABLE_DROPS)); then
                class_parts+=("unstable")
                unstable=1
            fi
            tooltip_parts+=("$kind: $model" "Battery: $pct%" "State: $state" \
                "Link drops (last ${RECONNECT_WINDOW_MIN} min): $drops")
            printf '%s\t%s\t%s\n' "$model" "$pct" "$(date +%s)" >>"$CACHE_FILE.tmp"
        else
            text_parts+=("$icon --")
            class_parts+=("off")
            tooltip_parts+=("$kind: $model" "Battery: not reported")
        fi
    done < <(upower -e 2>/dev/null || true)

    if ((have_connected)); then
        if [ -s "$CACHE_FILE.tmp" ]; then
            mv "$CACHE_FILE.tmp" "$CACHE_FILE"
        else
            rm -f "$CACHE_FILE.tmp"
        fi
    else
        rm -f "$CACHE_FILE.tmp"
        prune_cache
        local seen
        while IFS=$'\t' read -r model pct seen; do
            [ -n "${model:-}" ] || continue
            text_parts+=("$KEYBOARD_ICON $pct%")
            class_parts+=("off")
            tooltip_parts+=("$model" "Battery: $pct% (last seen $(relative_time "$seen"))" \
                "Link is down. The last battery reading was $pct%.")
        done < <(cat "$CACHE_FILE" 2>/dev/null || true)
    fi

    if ((${#text_parts[@]} == 0)); then
        printf '{"text": "%s", "tooltip": "No Bluetooth keyboard or mouse known yet", "class": "off"}\n' "$KEYBOARD_ICON"
        return
    fi

    if ((unstable)); then
        tooltip_parts+=("" "Many reconnects: weak link or a driver problem, not low battery.")
    fi

    local text tooltip class
    text="$(IFS=' '; echo "${text_parts[*]}")"
    tooltip="$(printf '%s\n' "${tooltip_parts[@]}")"
    class="$(IFS=' '; echo "${class_parts[*]}")"

    printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' \
        "$(json_escape "$text")" "$(json_escape "$tooltip")" "$(json_escape "$class")"
}

main "$@"
