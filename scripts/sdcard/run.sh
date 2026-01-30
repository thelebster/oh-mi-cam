#!/bin/sh
# Load U-Boot environment variables from uenv.txt
# Runs every boot - just edit uenv.txt and reboot to apply changes

UENV="/mnt/mmcblk0p1/uenv.txt"
[ -f "$UENV" ] || exit 0

tmp=$(mktemp)
sed '/^#/d; /^$/d; s/=/ /' "$UENV" > "$tmp"
fw_setenv -s "$tmp"
rm "$tmp"
