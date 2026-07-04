# single-dGPU-passthrough


> ## Disclaimer
This is **_not a guide_**. This is my **_personal_** setup for QEMU/VFIO with single dGPU passthrough on Plasma Wayland. However the references at the bottom are actual guides. This is documenting the issues I had (And I've seen others have similar issues)
<sub>
>  Honestly you're probably better off dual-booting.
>
> Kernel-level anti-cheats are getting increasingly aggressive about fucking over VM users, and there's always a chance your favourite game simply won't run (or worse, ban you).
>
>**That said...** this shit is pretty cool to get working.     
>   <sub>And earn bragging rights</sub></sub>



The `.rom` was extracted with GPU-Z, but should also be available through [TechPowerUp's vgabios catalogue](https://www.techpowerup.com/vgabios/).

If you're **not** going to extract your own `.rom`, be ***100% sure*** the `.rom` you download is the correct one.

## Setup this was done on

- Host OS: EndeavourOS
- Display Server: Plasma (Wayland)
- Hypervisor: QEMU/KVM
- VM Manager: virt-manager
- GPU: 3080 TI (GA102)
- Guest OS: Windows 10
- Networking: VirtIO
- GPU hooks: libvirt qemu hooks

---

# This repo serves mainly as a backup for my own VFIO setup

**But** if you're having the same issues, the notes below may help.

**Easiest way to troubleshoot is to run the script over SSH**

# Issues encountered

- **Nvidia modules not unloading with `modprobe -r` Throwing error(s):**
    ```text
    FATAL: Module nvidia* is in use
    ```
    - This occurred even after stopping the display manager earlier in the script.

- **Getting stuck at a black screen. Script would stop and freeze the system when detaching the GPU** at the:
  ```
  virsh nodedev-detach $VIRSH_GPU_VIDEO
  ```
  section of the script. 
  **[sysRq](https://wiki.archlinux.org/title/Keyboard_shortcuts#Rebooting) to the rescue**
  
  <sub>(Simple guide to enable [SysRq](https://forum.manjaro.org/t/howto-reboot-turn-off-your-frozen-computer-reisub-reisuo/3855))</sub>

- **Networking not working in the VM**
  - The VM was originally configured with NIC device model `e1000e` but was unable to get an address from DHCP on the host machine.
  
    I still don't know why this was the case, as `e1000e` should *just work*™

    I tried many approaches but never got it working with that device model. The solution was switching to VirtIO and actually configuring it correctly (detailed in Solutions)
    VirtIO is the preferred device model anyway.
    
    <sub>Don't waste your time trying to make e1000e work</sub>

# Solutions

- **Nvidia modules not unloading with `modprobe -r`**
  ```text
  FATAL: Module nvidia* is in use
  ```
- **Getting stuck at a black screen. Script would stop and freeze the system when detaching the GPU** at:
  ```
  virsh nodedev-detach $VIRSH_GPU_VIDEO
  ```
  - Very simple fix. Added:
    ```
    systemctl --user -M $USER stop plasma*
    ```
    *Before* killing the display manager.
    
    Nvidia modules not unloading was due to (what I believe anyway) a quirk(?) with Wayland not stopping all the Nvidia-related modules Plasma was using even when the display manager was killed.

  If this doesn't solve it for you, uncomment:
  ```text
  fuser -v /dev/nvidia*
  lsof /dev/nvidia*
  cat /proc/driver/nvidia/clients
  modprobe -D nvidia
  ```
    in bind_vfio.sh and see what is death gripping the corresponding nvidia module(s)
  
    `virsh nodedev-detach $VIRSH_GPU_VIDEO`
  **Cannot be executed *before* the nvidia modules are unloaded, causing the freeze.**
- **Networking not working in the VM**
  - Switched the NIC device model to `VirtIO` and installed the VirtIO drivers in the Windows guest.
  - VirtIO drivers can be found here:
    - https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md
    - [Direct download](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso) to the driver.
      
    - Download the ISO, attach it to `SATA CDROM` in virt-manager, boot the VM and install the drivers.
   
      
## Directory structure
- Create
```
$ mkdir -p /etc/libvirt/hooks/qemu.d/<VM-NAME>/prepare/begin
$ mkdir -p /etc/libvirt/hooks/qemu.d/<VM-NAME>/release/end
```
- Should look like:
```
/etc/libvirt/hooks $ tree

├── kvm.conf
├── qemu
└── qemu.d
    └── <VM-NAME>
        ├── prepare
        │   └── begin
        │       └── bind_vfio.sh
        └── release
            └── end
                └── unbind_vfio.sh
```

## qemu hook source

```bash
sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' \
    -O /etc/libvirt/hooks/qemu
```

## IOMMU Groups

```
#!/bin/bash
for d in /sys/kernel/iommu_groups/*/devices/*; do
  n=${d#*/iommu_groups/*}; n=${n%%/*}
  printf 'IOMMU Group %s ' "$n"
  lspci -nns "${d##*/}"
done
```
> [!IMPORTANT]
> ***IF*** your GPU's Audio device/Vga controller/usb controller/GPU's *whatever* That you <ins>***need***</ins> to passthrough are <ins>***not***</ins> in the same IOMMU group, you need to do an [ACS Override Patch](https://queuecumber.gitlab.io/linux-acs-override/) This is a ***_major pain_*** in the ass.  
*Godspeed you unlucky bastard*


# TODO

- Optimize Windows performance, CPU freq. is pinned below boost. GPU utilization seems to be capped somewhere.
- ~~Fix Windows detecting VM environment~~ Unsure if this is a good idea seeing some anticheats detecting this and some reports of people getting banned on VMs with hidden states.


## References
- [Bryan Steiner GPU Passthrough Tutorial](https://github.com/bryansteiner/gpu-passthrough-tutorial)
- [Bryan Steiner GPU Passthrough Tutorial](https://github.com/QaidVoid/Complete-Single-GPU-Passthrough)
- [Arch Wiki - PCI passthrough via OVMF](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [PassthroughPOST VFIO Tools](https://github.com/PassthroughPOST/VFIO-Tools)
