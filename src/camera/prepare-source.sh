#!/usr/bin/env bash
# Install native camera DT overlay into the prepared kernel source.
set -Eeuo pipefail
[[ $# == 1 && -d $1 ]] || exit 2
kernel=$(realpath "$1")
here=$(cd -- "$(dirname -- "$0")" && pwd)
version=$(jq -er .version "$kernel/senemos-adaptation/source-lock.json")
case $version in 7.2.9|7.2.10|7.2.11|7.2.12|7.3.0|7.3.1) ;; *) exit 1;; esac
[[ $(awk '/^VERSION =/ {v=$3} /^PATCHLEVEL =/ {p=$3} /^SUBLEVEL =/ {s=$3} END {print v "." p "." s}' "$kernel/Makefile") == "$version" ]]
target=$kernel/arch/arm64/boot/dts/qcom
[[ -d $target ]]
# Install camera DT overlay for OV13B10 (rear) and OV08D10 (front)
install -m644 "$here/sm7675-uke-native-camera.dtso" "$target/sm7675-uke-native-camera.dtso"
# Ensure it's included in the DT build
makefile=$target/Makefile
if ! grep -q "sm7675-uke-native-camera.dtbo" "$makefile"; then
    sed -i '/^dtb-.*sm7675.*\.dtbo/a\dtb-$(CONFIG_ARCH_SM7675) += sm7675-uke-native-camera.dtbo' "$makefile"
fi
printf 'Native camera DT overlay installed for kernel DT build\n'