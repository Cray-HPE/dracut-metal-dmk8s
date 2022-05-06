#!/bin/bash
#
# MIT License
#
# (C) Copyright 2022 Hewlett Packard Enterprise Development LP
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
[ "${metal_debug:-0}" = 0 ] || set -x

command -v info > /dev/null 2>&1 || . /lib/dracut-lib.sh

make_ephemeral() {

    # Check if the disks exists and cancel if they do.
    local conrun_scheme=${metal_conrun%=*}
    local conrun_authority=${metal_conrun#*=}
    local conlib_scheme=${metal_conlib%=*}
    local conlib_authority=${metal_conlib#*=}
    local k8slet_scheme=${metal_k8slet%=*}
    local k8slet_authority=${metal_k8slet#*=}
    local disks=()
    disks+=( "/dev/disk/by-${conrun_scheme,,}/${conrun_authority^^}" )
    disks+=( "/dev/disk/by-${conlib_scheme,,}/${conlib_authority^^}" )
    disks+=( "/dev/disk/by-${k8slet_scheme,,}/${k8slet_authority^^}" )
    for disk in "${disks[@]}"; do 
        if blkid -s UUID -o value "$disk" >/dev/null; then

            # echo 0 to signal that nothing was done; the disks exist
            echo 0 > /tmp/metalephemeraldisk.done
        else
            # A disk doesn't exist yet.
            # Remove the file if it was created and then exit the loop to start making the disks.
            rm -f /tmp/metalephemeraldisk.done
            break
        fi
    done
    [ -f /tmp/metalephemeraldisk.done ] && return
    
    local target="${1:-}" && shift
    [ -z "$target" ] && info 'No ephemeral disk.' && return 0

    parted --wipesignatures -m --align=opt --ignore-busy -s "/dev/${target}" -- mktable gpt \
        mkpart extended xfs 2048s "${metal_size_conrun:-75}GB" \
        mkpart extended xfs "${metal_size_conrun:-75}GB" "${metal_size_conlib:-25}%" \
        mkpart extended xfs "${metal_size_conlib:-25}%" "$((${metal_size_conlib:-25} + ${metal_size_k8slet:-25}))%"

    # NVME partitions have a "p" to delimit the partition number.
    if [[ "$target" =~ "nvme" ]]; then
        target="${target}p" 
    fi

    # NOTE: These don't persist, but are appropriate to add in-case they ever do.
    sleep 2
    mkfs.xfs -f -L ${metal_conrun#*=} "/dev/${target}1" || warn Failed to create "${metal_conrun#*=}"
    sleep 2
    mkfs.xfs -f -L ${metal_conlib#*=} "/dev/${target}2" || warn Failed to create "${metal_conlib#*=}"
    sleep 2
    mkfs.xfs -f -L ${metal_k8slet#*=} "/dev/${target}3" || warn Failed to create "${metal_k8slet#*=}"

    mkdir -p /run/containerd /var/lib/kubelet /var/lib/containerd /run/lib-containerd
    #shellcheck disable=SC2154
    {
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${metal_conrun}" /run/containerd xfs "$metal_fsopts_xfs"
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${metal_conlib}" /run/lib-containerd xfs "$metal_fsopts_xfs"
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${metal_k8slet}" /var/lib/kubelet xfs "$metal_fsopts_xfs"
    } >>$metal_fstab

    # Mount FS to allow creation of necessary overlayFS directories; might as well mount everything with -a.
    mount -a -v -T $metal_fstab && mkdir -p /run/lib-containerd/ovlwork /run/lib-containerd/overlayfs
    printf '% -18s\t% -18s\t%s\t%s 0 0\n' containerd_overlayfs /var/lib/containerd overlay lowerdir=/var/lib/containerd,upperdir=/run/lib-containerd/overlayfs,workdir=/run/lib-containerd/ovlwork >>$metal_fstab
    # Mount FS again, catching our new overlayFS. Failure to mount here is fatal.
    mount -a -v -T $metal_fstab

    # echo 1 to signal that this module create a disk.
    echo 1 > /tmp/metalephemeraldisk.done && return
}
