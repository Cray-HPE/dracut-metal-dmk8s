# METAL 93dmk8s - persistent kubernetes device-maps 

This module deploys an ephemeral disk to be used by kubernetes containers:

- `/run/containerd` partition
- `/var/lib/kubelet` partition
- `/var/lib/containerd` partition

## Table of Contents

- [Parameters](README.md#parameters)
    - [Customizable Parameters](README.md#customizable-parameters) 
        - [FSLabel Parameters](README.md#fslabel-parameters)
            - [`metal.disk.conrun`](README.md#metaldiskconrun)
            - [`metal.disk.conlib`](README.md#metaldiskconlib)
            - [`metal.disk.k8slet`](README.md#metaldiskk8slet)
        - [Partition Size Parameters](README.md#partition-size-parameters)
            - [`metal.disk.conrun.size`](README.md#metaldiskconrunsize)
            - [`metal.disk.conlib.size`](README.md#metaldiskconlibsize)
            - [`metal.disk.k8slet.size`](README.md#metaldiskk8sletsize)
    - [Required Parameters](README.md#required-parameters)
    - [`metal.server`](README.md#metalserver)

## Parameters

The `unit` of size varies per-parameter; pay attention to avoid undesirable partition tables

### Customizable Parameters

### FSLabel Parameters

The FS labels can be changed from their default values.
This may be desirable for cases when another LVM is being re-used.

##### `metal.disk.conrun`

> FSLabel for the `/run/containerd`.
> - `Default: CONRUN`

##### `metal.disk.conlib`

> FSLabel for the `/var/lib/containerd`.
> - `Default: CONLIB`

##### `metal.disk.k8slet`

> FSLabel for the `/var/lib/kubelet`.
> - `Default: K8SLET`

### Partition Size Parameters

##### `metal.disk.conrun.size`

> Size of the `/run/containerd` partition, measured in gigabytes (`GB`):
> - `Default: 75`
> - `Min: 10`
> - `Max: 150`

##### `metal.disk.conlib.size` 

> Size of the `/var/lib/containerd` partition, measured in percentage (`%`):
> - `Default: 40`
> - `Min: 10`
> - `Max: 45`

##### `metal.disk.k8slet.size`

> Size of the `/var/lib/kubelet` partition, measured in percentage (`%`):
> - `Default: 10`
> - `Min: 10`
> - `Max: 45`

### Required Parameters

The following parameters are required for this module to work, however they belong to the native dracut space.

> See [`module-setup.sh`](./93metaldmk8s/module-setup.sh) for the full list of module and driver dependencies.

##### `metal.server`

> Enable or disable this module. This parameter has no other effect on 93dmk8s other than indicating that the active node is currently (re)building and requires partitions.
> This module depends on 90metalmdsquash, that module entails filling in the `metal.server` parameter.
