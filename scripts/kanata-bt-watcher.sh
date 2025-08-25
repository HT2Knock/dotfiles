#!/bin/bash

PEBBLE_MAC="DA:5D:71:C5:1E:10"

bluetoothctl --monitor | while read -r line; do
    if echo "$line" | grep -q "Device $PEBBLE_MAC Connected: yes"; then
        echo "[$(date)] $MAC connected – restarting kanata"
        systemctl --user restart kanata.service
    fi
done
