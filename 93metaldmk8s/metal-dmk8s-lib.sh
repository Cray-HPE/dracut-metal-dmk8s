#!/bin/bash
#
# MIT License
#
# (C) Copyright 2022-2024 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# metal-dmk8s-lib.sh
[ "${METAL_DEBUG:-0}" = 0 ] || set -x

export EPHEMERAL_DONE_FILE=/tmp/metalephemeraldisk.done

command -v info > /dev/null 2>&1 || . /lib/dracut-lib.sh

##############################################################################
# function: scan_ephemeral
#
# Creates a "done" file if the ephemeral disk and its partitions exist.
#
scan_ephemeral() {
    local conrun_scheme=${METAL_CONRUN%=*}
    local conrun_authority=${METAL_CONRUN#*=}
    local conlib_scheme=${METAL_CONLIB%=*}
    local conlib_authority=${METAL_CONLIB#*=}
    local k8slet_scheme=${METAL_K8SLET%=*}
    local k8slet_authority=${METAL_K8SLET#*=}
    local disks=()
    disks+=( "/dev/disk/by-${conrun_scheme,,}/${conrun_authority^^}" )
    disks+=( "/dev/disk/by-${conlib_scheme,,}/${conlib_authority^^}" )
    disks+=( "/dev/disk/by-${k8slet_scheme,,}/${k8slet_authority^^}" )
    for disk in "${disks[@]}"; do
        if blkid -s UUID -o value "$disk" >/dev/null; then

            # echo 0 to signal that nothing was done; the disks exist
            echo 0 > $EPHEMERAL_DONE_FILE
        else
            # A disk doesn't exist yet.
            # Remove the file if it was created and then exit the loop to start making the disks.
            rm -f $EPHEMERAL_DONE_FILE
            break
        fi
    done
}

##############################################################################
# function: make_ephemeral
#
# Returns 0 if a disk was partitioned, otherwise this calls
# metal_die with a contextual error message.
#
# Requires 1 argument for which disk:
#
#   sda
#   nvme0
#
# NOTE: The disk name must be given without any partitions or `/dev` prefixed
#       paths.
make_ephemeral() {

    local target="${1:-}" && shift
    [ -z "$target" ] && info 'No ephemeral disk.' && return 0
    command -v _trip_udev > /dev/null 2>&1 || . /lib/metal-lib.sh

    parted --wipesignatures -m --align=opt --ignore-busy -s "/dev/${target}" -- mktable gpt \
        mkpart extended xfs 2048s "${METAL_SIZE_CONRUN:-75}GB" \
        mkpart extended xfs "${METAL_SIZE_CONRUN:-75}GB" "${METAL_SIZE_CONLIB:-25}%" \
        mkpart extended xfs "${METAL_SIZE_CONLIB:-25}%" "$((${METAL_SIZE_CONLIB:-25} + ${METAL_SIZE_K8SLET:-25}))%"

    # NVME partitions have a "p" to delimit the partition number.
    if [[ "$target" =~ "nvme" ]]; then
        nvme=1
    fi

    partprobe "/dev/${target}"
    _trip_udev
    mkfs.xfs -f -L "${METAL_CONRUN#*=}" "/dev/${target}${nvme:+p}1" || metal_dmk8s_die "Failed to create ${METAL_CONRUN#*=}"
    partprobe "/dev/${target}"
    _trip_udev
    mkfs.xfs -f -L "${METAL_CONLIB#*=}" "/dev/${target}${nvme:+p}2" || metal_dmk8s_die "Failed to create ${METAL_CONLIB#*=}"
    partprobe "/dev/${target}"
    _trip_udev
    mkfs.xfs -f -L "${METAL_K8SLET#*=}" "/dev/${target}${nvme:+p}3" || metal_dmk8s_die "Failed to create ${METAL_K8SLET#*=}"

    mkdir -p /run/containerd /var/lib/kubelet /var/lib/containerd
    {
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${METAL_CONRUN}" /run/containerd xfs "$METAL_FSOPTS_XFS"
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${METAL_CONLIB}" /var/lib/containerd xfs "$METAL_FSOPTS_XFS"
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${METAL_K8SLET}" /var/lib/kubelet xfs "$METAL_FSOPTS_XFS"
    } >> "$METAL_FSTAB"

    # Mount filesystems. Failure to mount here is fatal.
    mount -a -v -T "$METAL_FSTAB"

    # echo 1 to signal that this module create a disk.
    echo 1 > $EPHEMERAL_DONE_FILE && return
}


##############################################################################
# function: metal_dmk8s_die
#
# Calls metal_die, printing this module's URL to its source code first.
#
metal_dmk8s_die() {
    command -v metal_die > /dev/null 2>&1 || . /lib/metal-lib.sh
    echo >&2 "GitHub/Docs: https://github.com/Cray-HPE/dracut-metal-dmk8s"
    metal_die "$@"
}
