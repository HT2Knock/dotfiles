#!/bin/sh

# TokyoNight (Night) Color Palette
BG='#1a1b26'        # Background
FG='#c0caf5'        # Foreground (text)
ACCENT='#7aa2f7'    # Accent (ring, highlights)
WRONG='#f7768e'     # Wrong password ring
VERIFYING='#bb9af7' # Verifying color
KEYHL='#7dcfff'

i3lock \
	--nofork \
	--insidever-color=$BG \
	--ringver-color=$VERIFYING \
	\
	--insidewrong-color=$BG \
	--ringwrong-color=$WRONG \
	\
	--inside-color=$BG \
	--ring-color=$ACCENT \
	--line-color=$BG \
	--separator-color=$ACCENT \
	\
	--verif-color=$FG \
	--wrong-color=$WRONG \
	--time-color=$FG \
	--date-color=$FG \
	--layout-color=$FG \
	--keyhl-color=$KEYHL \
	--bshl-color=$WRONG \
	\
	--wrong-text="Invalid" \
	--verif-text="Checking..." \
	\
	--wrong-font="JetBrains Mono" \
	--verif-font="JetBrains Mono" \
	--time-font="JetBrains Mono" \
	--date-font="JetBrains Mono" \
	--layout-font="JetBrains Mono" \
	--screen 2 \
	--blur 15 \
	--clock \
	--indicator \
	--time-str="%H:%M" \
	--date-str="%Y-%m-%d"
