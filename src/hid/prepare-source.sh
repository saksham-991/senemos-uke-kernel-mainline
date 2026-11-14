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
printf '\n' >> "$kernel/drivers/hid/Kconfig"
cat "$here/Kconfig" >> "$kernel/drivers/hid/Kconfig"
printf '\nobj-$(CONFIG_HID_NANOSIC_WN8030) += hid-nanosic-wn8030.o\n' >> "$kernel/drivers/hid/Makefile"
printf 'Nanosic WN8030 driver staged\n'
