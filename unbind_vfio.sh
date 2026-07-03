#!/bin/bash
#echo "HOOK END $(date)" >> /tmp/libvirt-hook-end.log
set -x
## Load the config file
source "/etc/libvirt/hooks/kvm.conf"
modprobe -r vfio
modprobe -r vfio_iommu_type1
modprobe -r vfio_pci

## Unbind gpu from vfio and bind to nvidia
virsh -c qemu:///system nodedev-reattach $VIRSH_GPU_VIDEO
virsh -c qemu:///system nodedev-reattach $VIRSH_GPU_AUDIO

nvidia-xconfig --query-gpu-info > /dev/null 2>&1
#load nvidia
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe nvidia
#restart display service and hopefully wayland xd
systemctl start sddm.service
