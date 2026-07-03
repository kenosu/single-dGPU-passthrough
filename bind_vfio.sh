#!/bin/bash
echo "HOOK START $(date)" >> /tmp/libvirt-hook.log
set -x
## Load the config file
#en haug med debug mannskit fra helvete her
#linjer: 15-20 burde kunne fucke off men lar ligge en så lenge.
source "/etc/libvirt/hooks/kvm.conf"
systemctl --user -M keno stop plasma*
systemctl stop sddm
sleep 1
modprobe -r nvidia_drm #|| exit 1
modprobe -r nvidia_modeset # || exit 1
modprobe -r nvidia_uvm #|| exit 1
modprobe -r nvidia #|| exit 1
sleep 2
#fuser -v /dev/nvidia*
#lsof /dev/nvidia*
#cat /proc/driver/nvidia/clients
#modprobe -D nvidia
## Load vfio
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_pci
#sleep 1
virsh -c qemu:///system nodedev-detach "$VIRSH_GPU_VIDEO"
virsh -c qemu:///system nodedev-detach "$VIRSH_GPU_AUDIO"
#virsh nodedev-detach $VIRSH_GPU_VIDEO
#virsh nodedev-detach $VIRSH_GPU_AUDIO
