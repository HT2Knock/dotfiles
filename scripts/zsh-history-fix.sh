#!/usr/bin/env bash

mv "$HOME"/.local/share/zsh/history "$HOME"/.local/share/zsh/history-bad

strings "$HOME"/.local/share/zsh/history-bad > "$HOME"/.local/share/zsh/history

fc -R "$HOME"/.local/share/zsh/history

rm "$HOME"/.local/share/zsh/history-bad
