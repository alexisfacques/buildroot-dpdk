# buildroot-dpdk

Patches and Makefiles for compiling DPDK (Data Plane Development Kit) with Buildroot. This package includes an option to install either DPDK version 18.11 (first cross-compilation release) for old Linux Kernels (>= 3.2); or version 19.02 for more recent Kernels (>= 3.16).

### Installing

Easy import using `BR2_EXTERNAL`. From your buildroot directory:

```
make BR2_EXTERNAL=path/to/buildroot_dpdk menuconfig
```
