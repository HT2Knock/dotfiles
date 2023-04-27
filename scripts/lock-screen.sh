#!/bin/sh

BLANK='#3b4252'
CLEAR='#434c5e'
DEFAULT='#2e3440'
TEXT='#81a1c1'
WRONG='#5e81ac'
WRONG_TEXT='#bf616a'
VERIF_TEXT='#8fbcbb'
VERIFYING='#d8dee9'

i3lock \
    --insidever-color=$CLEAR     \
    --ringver-color=$VERIFYING   \
    \
    --insidewrong-color=$CLEAR   \
    --ringwrong-color=$WRONG     \
    \
    --inside-color=$BLANK        \
    --ring-color=$DEFAULT        \
    --line-color=$BLANK          \
    --separator-color=$DEFAULT   \
    \
    --verif-color=$VERIF_TEXT    \
    --wrong-color=$WRONG_TEXT    \
    --time-color=$TEXT           \
    --date-color=$TEXT           \
    --layout-color=$TEXT         \
    --keyhl-color=$WRONG         \
    --bshl-color=$WRONG          \
    \
    --wrong-text="xxx"           \
    --verif-text="..."           \
    \
    --wrong-font="JetBrains Mono" \
    --verif-font="JetBrain Mono"  \
    --time-font="JetBrains Mono"  \
    --date-font="JetBrains Mono"  \
    --screen 1                   \
    --blur 10                     \
    --clock                      \
    --indicator                  \
    --time-str="%H:%M"           \
    --date-str="%Y-%m-%d"       \
