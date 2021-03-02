#!/bin/sh

# DEVICES EXIST or DIE
[ -f /tmp/metalephemeraldisk.done ] && exit 0
ls /dev/sd* > /dev/null 2>&1 || exit 1

# SUBBROUTINES
type make_ephemeral > /dev/null 2>&1 || . /lib/metal-dmk8s-lib.sh

# DISKS or RETRY
# Ignore whatever was selected for the overlay by starting +1 from that index.
disk_index=$((${metal_disks:-2} + 1))
ephemeral="$(lsblk -b -l -o SIZE,NAME,TYPE,TRAN | grep -E '(sata|nvme|sas)' | sort -h | awk '{print $1 " " $2}' | tail -n +${disk_index} | tr '\n' ' ')"
[ -z "${ephemeral}" ] && exit 1
ephemeral_size="$(echo $ephemeral | awk '{print $1}')"
# 1048576000000 is 1 TiB; required for this disk.
# exit 0 ; this module does not need to run on this node unless it meets the requirements.
[ "${ephemeral_size}" -lt 1048576000000 ] && exit 0

# DISKS
ephemeral_disk="$(echo $ephemeral | awk '{print $2}')"
if [ "${metal_nowipe:-0}" = 0 ]; then
    [ ! -f /tmp/metalephemeraldisk.done ] && make_ephemeral "$ephemeral_disk"
fi
