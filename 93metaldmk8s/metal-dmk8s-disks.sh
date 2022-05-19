#!/bin/bash

# DEVICES EXIST or DIE
[ -f /tmp/metalephemeraldisk.done ] && exit 0
ls /dev/sd* > /dev/null 2>&1 || exit 1

# SUBBROUTINES
type make_ephemeral > /dev/null 2>&1 || . /lib/metal-dmk8s-lib.sh
type metal_resolve_disk > /dev/null 2>&1 || . /lib/metal-lib.sh

# DISKS or RETRY
# Offset the selection; choose any disk that wasn't selected by the RAID.
# MAINTAINER NOTE: Regardless of gcp mode, this will ignore any NVME partition incase they stick around after wiping.
disk_offset=$((${metal_disks:-2} + 1))
ephemeral="$(metal_scand $disk_offset)"
[ -z "${ephemeral}" ] && exit 1

# Find the right disk.
# 1048576000000 is 1 TiB; required for this disk.
# exit 0 ; this module does not need to run on this node unless it meets the requirements.
ephemeral_disk=$(metal_resolve_disk "$ephemeral" $metal_disk_large) || exit 0

# Process the disk.
if [ "${metal_nowipe:-0}" = 0 ]; then
    [ ! -f /tmp/metalephemeraldisk.done ] && make_ephemeral "$ephemeral_disk"
fi
