#!/usr/bin/env bash
set -euo pipefail

readonly MOUNT_POINT="/mnt/work"
readonly DATA_DIR="/mnt/work/backup"

log() { printf '[setup-backup] %s\n' "$*"; }

if [[ $EUID -ne 0 ]]; then
	echo "Run as root: sudo $0" >&2
	exit 1
fi

log "Installing restic"
pacman -S --needed --noconfirm restic

if ! grep -q "[[:space:]]${MOUNT_POINT}[[:space:]]" /etc/fstab; then
	echo "No fstab entry for $MOUNT_POINT. Run scripts/format-backup-disk.sh first." >&2
	exit 1
fi

log "Mounting backup disk"
systemctl daemon-reload
mountpoint -q "$MOUNT_POINT" || mount "$MOUNT_POINT"
findmnt "$MOUNT_POINT"

DATA_OWNER="${SUDO_USER:-root}"
readonly DATA_OWNER
log "Creating $DATA_DIR owned by $DATA_OWNER"
mkdir -p "$DATA_DIR"
chown "$DATA_OWNER:$DATA_OWNER" "$DATA_DIR"

log "Done"
log "Next: run ~/dotfiles/scripts/backup.sh"
