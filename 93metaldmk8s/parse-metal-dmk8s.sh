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
# parse-metal-dmk8s.sh

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh

getargbool 0 metal.debug -d -y metal_debug && metal_debug=1
[ "${metal_debug:-0}" = 0 ] || set -x

metal_conrun=$(getarg metal.disk.conrun)
[ -z "${metal_conrun}" ] && metal_conrun=LABEL=CONRUN
metal_conlib=$(getarg metal.disk.conlib)
[ -z "${metal_conlib}" ] && metal_conlib=LABEL=CONLIB
metal_k8slet=$(getarg metal.disk.k8slet)
[ -z "${metal_k8slet}" ] && metal_k8slet=LABEL=K8SLET

# Affixed siz(s):
metal_size_conrun=$(getargnum 75 10 150 metal.disk.conrun.size)
# Percentages as size(s):
metal_size_conlib=$(getargnum 40 10 45 metal.disk.conlib.size)
metal_size_k8slet=$(getargnum 10 10 45 metal.disk.k8slet)

getargbool 0 metal.no-wipe -d -y metal_nowipe && metal_nowipe=1 || metal_nowipe=0

export metal_debug
export metal_conrun
export metal_conlib
export metal_k8slet
export metal_size_conrun
export metal_size_conlib
export metal_size_k8slet
export metal_nowipe
