#!/usr/bin/env bash
# Prepare native OV08D10 and OV13B10 sensor drivers on the retained kernel.
set -Eeuo pipefail
kernel=$(realpath "${1:?prepared kernel}")
here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
overlays=(sensors/0001-dt-bindings-media-ov13b10.patch
    sensors/0002-media-i2c-ov13b10-of-match.patch
    sensors/0003-ov08d10-probe-debug-lanes.patch
    sensors/0004-ov08d10-exposure-read-errors.patch)
for path in "${overlays[@]}"; do
    git -C "$kernel" apply --check "$here/$path"
    git -C "$kernel" apply "$here/$path"
done
# Kernel config (CONFIG_VIDEO_OV08D10/OV13B10) is set in packaging/native/native.config
# Verify DT binding installed
test -s "$kernel/Documentation/devicetree/bindings/media/i2c/ovti,ov13b10.yaml"
printf 'Native camera sensor modules enabled; DT activation and firmware remain separate\n'