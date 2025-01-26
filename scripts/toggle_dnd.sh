#!/bin/bash

is_paused=$(dunstctl is-paused)

if [ "$is_paused" = "false" ]; then
	notify-send -u low -i face-cool "Do Not Disturb Enabled" \
		"Notifications will be silent. Stay focused! 🧘‍♂️"

	sleep 2

	dunstctl close
	dunstctl set-paused true
else
	dunstctl set-paused false

	notify-send -u low -i bell "Do Not Disturb Disabled" \
		"Notifications are back on. Don't miss any updates! 📬"
fi
