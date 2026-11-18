#!/usr/bin/env bash
# Explicit host-only staging; no kernel config or DT selection.
set -Eeuo pipefail
[[ $# == 1 && -d $1/drivers/hid ]] || exit 2
kernel=$(realpath "$1")
here=$(cd -- "$(dirname -- "$0")" && pwd)

if grep -q 'HID_NANOSIC_WN8030' "$kernel/drivers/hid/Kconfig"; then
    printf 'Nanosic WN8030 staging entry already exists\n' >&2; exit 1
fi

install -m644 "$here/hid-nanosic-wn8030.c" "$kernel/drivers/hid/hid-nanosic-wn8030.c"
install -m644 "$here/nanosic_hinge.h" "$kernel/include/uapi/linux/nanosic_hinge.h"
printf '\n' >> "$kernel/drivers/hid/Kconfig"
cat "$here/Kconfig" >> "$kernel/drivers/hid/Kconfig"
printf '\nobj-$(CONFIG_HID_NANOSIC_WN8030) += hid-nanosic-wn8030.o\n' >> "$kernel/drivers/hid/Makefile"

# The MCU firmware is the OEM Pad 7 (O81) blob. CONFIG_EXTRA_FIRMWARE embeds it
# in the Image, and built-in firmware is consulted before any filesystem path,
# so the keyboard can come up in the initramfs and does not depend on the
# rootfs carrying the file. Stage it where a relative EXTRA_FIRMWARE_DIR points.
install -Dm644 "$here/firmware/nanosic/MCU_Upgrade.bin" \
    "$kernel/firmware/nanosic/MCU_Upgrade.bin"
printf 'Nanosic WN8030 driver and O81 firmware staged\n'
