#!/bin/bash

type info > /dev/null 2>&1 || . /lib/dracut-lib.sh

metal_conrun=$(getarg metal.disk.conrun)
[ -z "${metal_conrun}" ] && metal_conrun=LABEL=CONRUN
metal_conlib=$(getarg metal.disk.conlib)
[ -z "${metal_conlib}" ] && metal_conlib=LABEL=CONLIB
metal_k8slet=$(getarg metal.disk.k8slet)
[ -z "${metal_k8slet}" ] && metal_k8slet=LABEL=K8SLET

metal_fstab=/etc/fstab.metal
fsopts_xfs=noatime,largeio,inode64,swalloc,allocsize=131072k

make_ephemeral() {
    local target="${1:-}" && shift
    [ -z "$target" ] && info 'No ephemeral disk.' && return 0

    parted --wipesignatures -m --align=opt --ignore-busy -s "/dev/${target}" -- mktable gpt \
        mkpart extended xfs 2048s "${metal_size_conrun:-75}GB" \
        mkpart extended xfs "${metal_size_conrun:-75}GB" "${metal_size_conlib:-25}%" \
        mkpart extended xfs "${metal_size_conlib:-25}%" "$((${metal_size_conlib:-25} + ${metal_size_k8slet:-25}))%"

    # NOTE: These don't persist, but are appropriate to add in-case they ever do.
    sleep 2
    mkfs.xfs -f -L ${metal_conrun#*=} "/dev/${target}1" || warn Failed to create "${metal_conrun#*=}"
    sleep 2
    mkfs.xfs -f -L ${metal_conlib#*=} "/dev/${target}2" || warn Failed to create "${metal_conlib#*=}"
    sleep 2
    mkfs.xfs -f -L ${metal_k8slet#*=} "/dev/${target}3" || warn Failed to create "${metal_k8slet#*=}"

    mkdir -p /run/containerd /var/lib/kubelet /var/lib/containerd /run/lib-containerd
    {
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${metal_conrun}" /run/containerd xfs "$fsopts_xfs"
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${metal_conlib}" /run/lib-containerd xfs "$fsopts_xfs"
        printf '% -18s\t% -18s\t%s\t%s 0 0\n' "${metal_k8slet}" /var/lib/kubelet xfs "$fsopts_xfs"
    } >>$metal_fstab

    # Mount FS to allow creation of necessary overlayFS directories; might as well mount everything with -a.
    mount -a -v -T $metal_fstab && mkdir -p /run/lib-containerd/ovlwork /run/lib-containerd/overlayfs
    printf '% -18s\t% -18s\t%s\t%s 0 0\n' containerd_overlayfs /var/lib/containerd overlay lowerdir=/var/lib/containerd,upperdir=/run/lib-containerd/overlayfs,workdir=/run/lib-containerd/ovlwork >>$metal_fstab
    # Mount FS again, catching our new overlayFS. Failure to mount here is fatal.
    mount -a -v -T $metal_fstab

    echo 1 > /tmp/metalephemeraldisk.done && return
}
