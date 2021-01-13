#!/bin/sh
#
# Copyright 2020 Hewlett Packard Enterprise Development LP
#
# live.overlay.readonly: Set to mark the entire overlayFS as read-only.
# > metal.disk.conrun.size=
#
# live.dir: This can change where the squashFS is stored within its storage.
# > rd.live.dir=LiveOS
#
type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh

getargbool 0 metal.debug -d -y metal_debug && metal_debug=1
# Afixed size:
metal_size_conrun=$(getargnum 75 10 150 metal.disk.conrun.size)
# Percentages as sizes
metal_size_conlib=$(getargnum 25 10 45 metal.disk.conlib.size)
metal_size_k8slet=$(getargnum 25 10 45 metal.disk.k8slet)

getargbool 0 metal.no-wipe -d -y metal_nowipe && metal_nowipe=1 || metal_nowipe=0

export metal_debug
export metal_size_conrun
export metal_size_conlib
export metal_size_k8slet
export metal_nowipe
