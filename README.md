# single-dGPU-passthrough
My **_personal_** setup for QEMU/VFIO with single dGPU passthrough on Plasma Wayland. plus patched ROM files for GA102 3080 TI

### .rom Extracted with gpu-z

# **TODO**
* Optimize Win performance, CPU freq. is pinned below boost. GPU Utilization seems to be capped somewhere.
*  ~~Fix windows detecting VM environment~~
*  
## **Structure**
```
$ mkdir -p /etc/libvirt/hooks/qemu.d/win10/prepare/begin && mkdir -p /etc/libvirt/hooks/qemu.d/win10/release/end
```
```
/etc/libvirt/hooks $ tree         

├── kvm.conf
├── qemu
└── qemu.d
    └── win10
        ├── prepare
        │   └── begin
        │       └── bind_vfio.sh
        └── release
            └── end
                └── unbind_vfio.sh
```
## **qemu hook source**
```
sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' \
     -O /etc/libvirt/hooks/qemu
```
## **IOMMU Groups**
```
#!/bin/bash
for d in /sys/kernel/iommu_groups/*/devices/*; do
  n=${d#*/iommu_groups/*}; n=${n%%/*}
  printf 'IOMMU Group %s ' "$n"
  lspci -nns "${d##*/}"
done
```
