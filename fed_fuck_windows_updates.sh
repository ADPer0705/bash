#!/bin/bash
set -euo pipefail

# ==================================================
# LUKS2 + TPM2 Auto-Unlock
# ==================================================
LUKS_DEVICE="/dev/nvme0n1p7"

echo "==> Re-enrolling TPM2 for LUKS auto-unlock..."

# Wipe existing tpm2 slot if present (ignore failure on first run)
sudo systemd-cryptenroll --wipe-slot=tpm2 "$LUKS_DEVICE" || true

# Enroll fresh TPM2 key
sudo systemd-cryptenroll \
	--tpm2-device=auto \
	--tpm2-pcrs=7 "$LUKS_DEVICE"

# ==================================================
# NVIDIA
# ==================================================
GRAPHICS_CARD="NVIDIA GeForce RTX 4060"
GRAPHICS_MODULE="nvidia"
NVIDIA_REBUILT=false

rebuild_nvidia () {
	if [ "$NVIDIA_REBUILT" = true ]; then
		return 0
	fi
	echo "==> Rebuilding NVIDIA kernel modules..."
	sudo rm -rf /var/cache/akmods/nvidia/*
	sudo akmods --force --rebuild
	NVIDIA_REBUILT=true
}

echo "==> Checking NVIDIA driver state..."

# nvidia-smi may legitimately fail if driver is broken — don't let pipefail kill the script here
if ! nvidia-smi 2>/dev/null | grep -q "$GRAPHICS_CARD"; then
	echo "  - nvidia-smi cannot reach GPU"
	rebuild_nvidia
fi

if sudo systemctl is-failed --quiet akmods.service; then
	echo "  - akmods.service is in failed state"
	rebuild_nvidia
fi

if ! modinfo "$GRAPHICS_MODULE" &> /dev/null; then
	echo "  - nvidia module info unavailable"
	rebuild_nvidia
fi

if ! lsmod | grep -q "$GRAPHICS_MODULE"; then
	echo "  - nvidia module not loaded"
	rebuild_nvidia
fi

# NOTE: This script does not handle corruption of NVIDIA config
# files in /etc/modprobe.d/ or consequent conflicts with nouveau.

# ==================================================
# Time Sync
# ==================================================
echo "==> Verifying time sync configuration..."

TIMEDATE_STATUS=$(timedatectl status)

if echo "$TIMEDATE_STATUS" | grep -q "RTC in local TZ: yes"; then
	echo "  - RTC was set to local TZ, correcting to UTC"
	sudo timedatectl set-local-rtc 0 --adjust-system-clock
fi

if ! echo "$TIMEDATE_STATUS" | grep -q "NTP service: active"; then
	echo "  - NTP not active, enabling"
	sudo timedatectl set-ntp true
fi

# ==================================================
# Rebuild INITRAMFS (covers LUKS + NVIDIA changes above)
# ==================================================
echo "==> Regenerating initramfs..."
sudo dracut --force --regenerate-all

echo "==> Done."
