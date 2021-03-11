93dmk8s - persistent kubernetes device-maps 
===============

This module deploys an ephemeral disk to be used by kubernetes containers:

- `/run/containerd` partition
- `/var/lib/kubelet` partition
- `/run/lib-containerd` partition

# OverlayFS

In order to allow reading of the original material in `/var/lib/containerd` residing in the SquashFS image while offering persistent storage, an overlayFS is created.

Only `/var/lib/containerd` is an OverlayFS.
- Lower Directory (Read-Only): `/var/lib/containerd`
- Upper Directory (Writeable): `/run/lib-containerd`

> Existing data from the root OverlayFS and the squashFS will be read-only at that location once the `containerd_overlayfs` is mounted.

For more information on the OverlayFS, see:
- [90metalmdsquash](https://github.com/Cray-HPE/dracut-metal-mdsquash#rootfs-and-the-persistent-overlayfs)
- [CSM Usage of OverlayFS](https://github.com/Cray-HPE/docs-csm-install/blob/main/104-NCN-PARTITIONING.md#overlayfs-and-persistence)
- [Kernel Documentation on OverlayFS](https://www.kernel.org/doc/html/latest/filesystems/overlayfs.html)

# Parameters

The `unit` of size varies per-parameter; pay attention to avoid undesirable partition tables

## FSLabels

The FS labels can be changed from their default values.
This may be desirable for cases when another LVM is being re-used.


#####  `metal.disk.conrun`

FSLabel for the `/run/containerd`.

Default: `CONRUN`

##### `metal.disk.conlib`

FSLabel for the `/run/lib-containerd`.

Default: `CONLIB`

##### `metal.disk.k8slet`

FSLabel for the `/var/lib/kubelet`.

Default: `K8SLET`

## Partition Sizes

#####  `metal.disk.conrun.size=75`

Size of the `/run/containerd` partition, measured in gigabytes (`GB`):

 - default: 75
 - min: 10
 - max: 150

##### `metal.disk.conlib.size=40` 

Size of the `/run/lib-containerd` partition, measured in percentage (`%`):
- default: 40
- min: 10
- max: 45

##### `metal.disk.k8slet.size=10` default:  25 min: 10 max: 45

Size of the `/var/lib/kubelet` partition, measured in percentage (`%`):
- default: 10
- min: 10
- max: 45
