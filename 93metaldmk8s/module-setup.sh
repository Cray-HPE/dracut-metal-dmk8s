#!/bin/bash
#
# MIT License
#
# (C) Copyright 2024 Hewlett Packard Enterprise Development LP
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
# module-setup.sh

# called by dracut
check() {
  require_binaries blkid lsblk mkfs.xfs mount parted partprobe || return 1
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
  inst_multiple chmod lsblk mkfs.xfs parted partprobe sort tail

  # shellcheck disable=SC2154
  inst_simple "$moddir/metal-dmk8s-lib.sh" "/lib/metal-dmk8s-lib.sh"
  inst_script "$moddir/metal-dmk8s-disks.sh" /sbin/metal-dmk8s-disks

  inst_hook cmdline 10 "$moddir/parse-metal-dmk8s.sh"
  inst_hook pre-udev 10 "$moddir/metal-dmk8s-genrules.sh"
  dracut_need_initqueue
}
