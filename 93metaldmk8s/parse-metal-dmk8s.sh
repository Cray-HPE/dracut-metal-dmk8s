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
# parse-metal-dmk8s.sh

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh

getargbool 0 metal.debug -d -y METAL_DEBUG && METAL_DEBUG=1
[ "${METAL_DEBUG:-0}" = 0 ] || set -x

METAL_CONRUN=$(getarg metal.disk.conrun)
[ -z "${METAL_CONRUN}" ] && METAL_CONRUN=LABEL=CONRUN
METAL_CONLIB=$(getarg metal.disk.conlib)
[ -z "${METAL_CONLIB}" ] && METAL_CONLIB=LABEL=CONLIB
METAL_K8SLET=$(getarg metal.disk.k8slet)
[ -z "${METAL_K8SLET}" ] && METAL_K8SLET=LABEL=K8SLET

# Affixed siz(s):
METAL_SIZE_CONRUN=$(getargnum 75 10 150 metal.disk.conrun.size)
# Percentages as size(s):
METAL_SIZE_CONLIB=$(getargnum 40 10 45 metal.disk.conlib.size)
METAL_SIZE_K8SLET=$(getargnum 10 10 45 metal.disk.k8slet)

getargbool 0 metal.no-wipe -d -y METAL_NOWIPE && METAL_NOWIPE=1 || METAL_NOWIPE=0

export METAL_DEBUG
export METAL_CONRUN
export METAL_CONLIB
export METAL_K8SLET
export METAL_SIZE_CONRUN
export METAL_SIZE_CONLIB
export METAL_SIZE_K8SLET
export METAL_NOWIPE
