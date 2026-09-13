#!/usr/bin/env bash
set -euo pipefail

readonly REPO="/mnt/work/backup/restic"
readonly PASSWORD_FILE="$HOME/.config/restic/password"

export RESTIC_REPOSITORY="$REPO"
export RESTIC_PASSWORD_FILE="$PASSWORD_FILE"

if [[ ! -f "$PASSWORD_FILE" ]]; then
	printf 'Missing password file: %s\n' "$PASSWORD_FILE" >&2
	printf 'Create it: mkdir -p ~/.config/restic && openssl rand -base64 32 > %s && chmod 600 %s\n' \
		"$PASSWORD_FILE" "$PASSWORD_FILE" >&2
	exit 1
fi

if [[ ! -f "$REPO/config" ]]; then
	restic init
fi

restic backup "$HOME" \
	--exclude-caches \
	--exclude "$HOME/.cache" \
	--exclude "$HOME/.npm" \
	--exclude "$HOME/.bun" \
	--exclude "$HOME/.cargo/registry" \
	--exclude "$HOME/.rustup" \
	--exclude "$HOME/go/pkg" \
	--exclude "$HOME/.local/share/nvim" \
	--exclude "$HOME/.local/share/zinit" \
	--exclude "$HOME/.local/share/Trash" \
	--exclude "$HOME/Pictures/walle" \
	--exclude "$HOME/.config/restic" \
	--tag "$(hostname -s)"

restic forget \
	--keep-daily 7 \
	--keep-weekly 4 \
	--keep-monthly 6 \
	--prune
