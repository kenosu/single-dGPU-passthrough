# single-dGPU-passthrough
My **_personal_** hook scripts and win XML for QEMU/VFIO with single GPU passthrough. plus patched ROM files for my 3080 TI 

# **TODO**
* Optimize Win performance, CPU freq. is pinned below boost
* Spoof windows detecting VM environment
* 
## **Structure**
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
