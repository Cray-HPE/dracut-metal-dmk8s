# METAL 93dmk8s - persistent kubernetes device-maps 

This module deploys an ephemeral disk to be used by kubernetes containers:

- `/run/containerd` partition
- `/var/lib/kubelet` partition
- `/run/lib-containerd` partition

# LVM

> _Coming Soon_

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

## Customizable Parameters

### FSLabel Parameters

The FS labels can be changed from their default values.
This may be desirable for cases when another LVM is being re-used.

##### `metal.disk.conrun=CONRUN`

> FSLabel for the `/run/containerd`.

##### `metal.disk.conlib=CONLIB`

> FSLabel for the `/run/lib-containerd`.

##### `metal.disk.k8slet=K8SLET`

> FSLabel for the `/var/lib/kubelet`.

### Partition Size Parameters

##### `metal.disk.conrun.size=75`

> Size of the `/run/containerd` partition, measured in gigabytes (`GB`):
> 
> * default: 75
> * min: 10
> * max: 150

##### `metal.disk.conlib.size=40` 

> Size of the `/run/lib-containerd` partition, measured in percentage (`%`):
> 
> * default: 40
> * min: 10
> * max: 45

##### `metal.disk.k8slet.size=10`

> Size of the `/var/lib/kubelet` partition, measured in percentage (`%`):
> 
> * default: 10
> * min: 10
> * max: 45

## Required Parameters

The following parameters are required for this module to work, however they belong to the native dracut space.

> See [`module-setup.sh`](./93metaldmk8s/module-setup.sh) for the full list of module and driver dependencies.

##### `metal.server`

> Enable or disable this module. This parameter has no other effect on 93dmk8s other than indicating that the active node is currently (re)building and requires partitions.
> This module depends on 90metalmdsquash, that module entails filling in the `metal.server` parameter.
