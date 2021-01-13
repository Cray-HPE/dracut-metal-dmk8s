Metal DMK8s Module
===============

This module deploys an ephemeral disk to be used by kubernetes containers:

- The `/run/containerd` partition
- The `/var/lib/kubelet` partition
- The `/var/lib/containerd` overlayFS

For information on partitioning and disks in Shasta, see [NCN Partitioning][1].


[1]: https://stash.us.cray.com/projects/MTL/repos/docs-non-compute-nodes/browse/104-NCN-PARTITIONING.md
