#!/bin/sh

fstab_metal='fstab.metal'
fstab_metal_new=/etc/$fstab_metal
fstab_metal_old=/run/initramfs/overlayfs/$fstab_metal
fstab_base=/run/rootfsbase/etc/fstab

[ ! -f $fstab_metal_new ] && exit 1

if [[ -f $fstab_metal_old ]]; then
    sort -u $fstab_base $fstab_metal_new $fstab_metal_old >${fstab_metal_old}.merge
    mv ${fstab_metal_old}.merge ${fstab_metal_old}
else
    cp ${fstab_metal_new} ${fstab_metal_old}
fi
