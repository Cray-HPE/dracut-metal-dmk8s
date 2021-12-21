#!/bin/bash
# module-setup.sh for metal-dmk8s

# called by dracut
check() {
    require_binaries mkfs.xfs parted || return 1
    return 
}

# called by dracut
depends() {
    # Needed so overlayFS is available, that's where the new fstab is dropped.
    echo metalmdsquash
    return 0
}

installkernel() {
    instmods hostonly=''
}

# called by dracut
install() {
    # the rest is needed by metal-squashfs-url-dract.
    # rmdir is needed by dmsquash-live/livenet
    inst_multiple chmod lsblk mkfs.xfs parted sort tail

    inst_simple "$moddir/metal-dmk8s-lib.sh" "/lib/metal-dmk8s-lib.sh"
    inst_script "$moddir/metal-dmk8s-disks.sh" /sbin/metal-dmk8s-disks

    inst_hook cmdline 10 "$moddir/parse-metal-dmk8s.sh"
    inst_hook pre-udev 10 "$moddir/metal-dmk8s-genrules.sh"
    dracut_need_initqueue
}
