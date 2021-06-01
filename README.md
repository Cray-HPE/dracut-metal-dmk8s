<a name="metal-93dmk8s---persistent-kubernetes-device-maps-"></a>
# METAL 93dmk8s - persistent kubernetes device-maps 

This module deploys an ephemeral disk to be used by kubernetes containers:

- `/run/containerd` partition
- `/var/lib/kubelet` partition
- `/run/lib-containerd` partition

## Table of Contents

* [OverlayFS](README.md#overlayfs)
* [Parameters](README.md#parameters)
    * [Customizable Parameters](README.md#customizable-parameters) 
        * [FSLabel Parameters](README.md#fslabel-parameters)
          * [`metal.disk.conrun`](README.md#metaldiskconrun)
          * [`metal.disk.conlib`](README.md#metaldiskconlib)
          * [`metal.disk.k8slet`](README.md#metaldiskk8slet)
        * [Partition Size Parameters](README.md#partition-size-parameters)
          * [`metal.disk.conrun.size`](README.md#metaldiskconrunsize)
          * [`metal.disk.conlib.size`](README.md#metaldiskconlibsize)
          * [`metal.disk.k8slet.size`](README.md#metaldiskk8sletsize)
    * [Required Parameters](README.md#required-parameters)
      * [`metal.server`](README.md#metalserver)


<a name="overlayfs"></a>
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

<a name="parameters"></a>
# Parameters

The `unit` of size varies per-parameter; pay attention to avoid undesirable partition tables

a name="customizable-parameters"></a>
## Customizable Parameters

<a name="fslabel-parameters"></a>
### FSLabel Parameters

The FS labels can be changed from their default values.
This may be desirable for cases when another LVM is being re-used.

<a name="`metal.disk.conrun`"></a>
##### `metal.disk.conrun`

> FSLabel for the `/run/containerd`.
> default: CONRUN

<a name="`metal.disk.conlib`"></a>
##### `metal.disk.conlib`

> FSLabel for the `/run/lib-containerd`.
> * default CONLIB

<a name="`metal.disk.k8slet`"></a>
##### `metal.disk.k8slet`

> FSLabel for the `/var/lib/kubelet`.
> * default: K8SLET

<a name="partition-size-parameters"></a>
### Partition Size Parameters

<a name="`metal.disk.conrun.siz`"></a>
##### `metal.disk.conrun.size`

> Size of the `/run/containerd` partition, measured in gigabytes (`GB`):
> 
> * default: 75
> * min: 10
> * max: 150

<a name="`metal.disk.conlib.size`-"></a>
##### `metal.disk.conlib.size` 

> Size of the `/run/lib-containerd` partition, measured in percentage (`%`):
> 
> * default: 40
> * min: 10
> * max: 45

<a name="`metal.disk.k8slet.size`"></a>
##### `metal.disk.k8slet.size`

> Size of the `/var/lib/kubelet` partition, measured in percentage (`%`):
> 
> * default: 10
> * min: 10
> * max: 45

<a name="required-parameters"></a>
## Required Parameters

The following parameters are required for this module to work, however they belong to the native dracut space.

> See [`module-setup.sh`](./93metaldmk8s/module-setup.sh) for the full list of module and driver dependencies.

<a name="`metal.server`"></a>
##### `metal.server`

> Enable or disable this module. This parameter has no other effect on 93dmk8s other than indicating that the active node is currently (re)building and requires partitions.
> This module depends on 90metalmdsquash, that module entails filling in the `metal.server` parameter.
