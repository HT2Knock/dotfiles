#!/usr/bin/env bash
set -euo pipefail

readonly ZRAM_CONF="/etc/systemd/zram-generator.conf"
readonly SNAPPER_CONF="/etc/snapper/configs/root"
readonly UPDATEDB_CONF="/etc/updatedb.conf"

log() { printf '[setup-system] %s\n' "$*"; }

if [[ $EUID -ne 0 ]]; then
	echo "Run as root: sudo $0" >&2
	exit 1
fi

log "Installing packages"
pacman -S --needed --noconfirm zram-generator snapper snap-pac btrfsmaintenance

log "Configuring zram swap"
cat >"$ZRAM_CONF" <<'EOF'
[zram0]
zram-size = min(ram, 8192)
compression-algorithm = zstd
EOF
systemctl daemon-reload
systemctl start systemd-zram-setup@zram0.service

if [[ ! -f "$SNAPPER_CONF" ]]; then
	log "Creating snapper root config"
	snapper -c root create-config /
fi

log "Tuning snapper limits"
for setting in \
	TIMELINE_LIMIT_HOURLY=5 \
	TIMELINE_LIMIT_DAILY=7 \
	TIMELINE_LIMIT_WEEKLY=0 \
	TIMELINE_LIMIT_MONTHLY=0 \
	TIMELINE_LIMIT_YEARLY=0 \
	NUMBER_LIMIT=10 \
	NUMBER_LIMIT_IMPORTANT=10; do
	snapper -c root set-config "$setting"
done

log "Enabling snapper timers"
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

log "Preventing locate from indexing snapshots"
if grep -q '^PRUNENAMES' "$UPDATEDB_CONF" 2>/dev/null; then
	if ! grep -q '\.snapshots' "$UPDATEDB_CONF"; then
		sed -i '/^PRUNENAMES/ s/"$/ .snapshots"/' "$UPDATEDB_CONF"
	fi
else
	printf 'PRUNENAMES = ".snapshots"\n' >>"$UPDATEDB_CONF"
fi

log "Enabling btrfs scrub timer"
systemctl enable --now btrfs-scrub.timer

log "Current swap"
swapon --show || true
log "Done"
