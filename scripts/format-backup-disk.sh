#!/usr/bin/env bash
set -euo pipefail

readonly DEV="${1:-/dev/sdb}"
readonly FSTAB="/etc/fstab"
readonly MOUNT_POINT="/mnt/work"
readonly LABEL="backup"

log() { printf '[format-backup-disk] %s\n' "$*"; }
die() {
	printf '[format-backup-disk] ERROR: %s\n' "$*" >&2
	exit 1
}

if [[ $EUID -ne 0 ]]; then
	echo "Run as root: sudo $0 [device]" >&2
	exit 1
fi

[[ -b "$DEV" ]] || die "$DEV is not a block device"

ROOT_SRC="$(findmnt -no SOURCE /)"
EFI_SRC="$(findmnt -no SOURCE /boot/efi 2>/dev/null || true)"
readonly ROOT_SRC EFI_SRC
if [[ "$ROOT_SRC" == "$DEV"* ]] || { [[ -n "$EFI_SRC" ]] && [[ "$EFI_SRC" == "$DEV"* ]]; }; then
	die "$DEV holds the running system"
fi

log "Unmounting $MOUNT_POINT"
umount "$MOUNT_POINT" 2>/dev/null || true

if lsblk -rno MOUNTPOINT "$DEV" | grep -q .; then
	die "$DEV still has mounted partitions; unmount them first"
fi

log "Target: $DEV"
lsblk -o NAME,SIZE,MODEL "$DEV"
read -r -p "This ERASES all data on $DEV. Type WIPE to continue: " reply
[[ "$reply" == "WIPE" ]] || die "Cancelled"

log "Removing old fstab entry"
sed -i "\|[[:space:]]${MOUNT_POINT}[[:space:]]|d" "$FSTAB"

log "Creating GPT and single partition"
wipefs -a "$DEV"
parted -s "$DEV" mklabel gpt
parted -s "$DEV" mkpart primary ext4 1MiB 100%
partprobe "$DEV"
udevadm settle

readonly PART="${DEV}1"
for _ in 1 2 3 4 5; do
	[[ -b "$PART" ]] && break
	sleep 1
done
[[ -b "$PART" ]] || die "Partition $PART did not appear"

log "Creating ext4 filesystem"
mkfs.ext4 -L "$LABEL" -m 1 "$PART"

UUID="$(blkid -s UUID -o value "$PART")"
readonly UUID
[[ -n "$UUID" ]] || die "Failed to read UUID of $PART"

log "Adding fstab entry"
printf 'UUID=%s %s ext4 defaults,noatime,nofail 0 2\n' "$UUID" "$MOUNT_POINT" >>"$FSTAB"

mkdir -p "$MOUNT_POINT"
systemctl daemon-reload
mount "$MOUNT_POINT"
findmnt "$MOUNT_POINT"

log "Done. New UUID: $UUID"
