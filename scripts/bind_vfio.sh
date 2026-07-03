#!/bin/bash
#make sure Hook actually executes. should no longer be an issue. but might aswell keep
echo "HOOK START $(date)" >> /tmp/libvirt-hook.log
set -x #debug
## Load the config file
#A bunch of debug shit at 16-19 incase nvidia drivers start acting up again.
source "/etc/libvirt/hooks/kvm.conf"
systemctl --user -M $USER stop plasma* #Seems to be necessary for wayland(?) haven't bothered testing too much. This workaround works just fine. unbind script is able to reload plasma just fine even with this.
systemctl stop sddm
sleep 1
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r nvidia_uvm
modprobe -r nvidia
sleep 2
#fuser -v /dev/nvidia*
#lsof /dev/nvidia*
#cat /proc/driver/nvidia/clients
#modprobe -D nvidia
## Load vfio
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_pci
#Using absolute paths just in case.
virsh -c qemu:///system nodedev-detach "$VIRSH_GPU_VIDEO" 
virsh -c qemu:///system nodedev-detach "$VIRSH_GPU_AUDIO"
#virsh nodedev-detach $VIRSH_GPU_VIDEO
#virsh nodedev-detach $VIRSH_GPU_AUDIO
