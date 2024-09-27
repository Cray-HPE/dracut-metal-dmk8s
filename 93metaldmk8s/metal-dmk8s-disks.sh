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
# metal-dmk8s-disks.sh
[ "${METAL_DEBUG:-0}" = 0 ] || set -x

# Wait for disks to exist.
command -v disks_exist > /dev/null 2>&1 || . /lib/metal-lib.sh
disks_exist || exit 1

# Now that disks exist it's worthwhile to load the library.
command -v make_ephemeral > /dev/null 2>&1 || . /lib/metal-dmk8s-lib.sh

# Wait for the pave function to wipe the disks if the wipe is enabled.
metal_paved || exit 1

# Check if our filesystems already exist.
scan_ephemeral

# Make the ephemeral disk if it didn't exist.
if [ ! -f "$EPHEMERAL_DONE_FILE" ]; then

    # Offset the search by the number of disks used up by the main metal dracut module.
    ephemeral=''
    disks="$(metal_scand)"
    IFS=" " read -r -a pool <<< "$disks"
    for disk in "${pool[@]}"; do
        if [ -n "${ephemeral}" ]; then
            break
        fi
        ephemeral=$(metal_resolve_disk "$disk" "$METAL_DISK_LARGE")
    done

    # If no disks were found, die.
    # When rd.luks is disabled, this hook-script expects to find a disk. Die if one isn't found.
    if [ -z "${ephemeral}" ]; then
        metal_dmk8s_die "No disks were found for ephemeral use."
        exit 1
    else
        echo >&2 "Found the following disk for ephemeral storage: $ephemeral"
    fi

    # Make the ephemeral disk.
    make_ephemeral "$ephemeral"
else
    echo 0 > "$EPHEMERAL_DONE_FILE"
fi

# If our disk was created, satisfy the wait_for_dev hook, otherwise keep waiting.
if [ -f "$EPHEMERAL_DONE_FILE" ]; then
    ln -s null /dev/metal-k8s
    exit 0
fi
