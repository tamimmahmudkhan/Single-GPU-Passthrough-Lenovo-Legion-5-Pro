#!/bin/bash
# Helpful to read output when debugging
set -x

# Stop display manager
systemctl stop display-manager.service
systemctl stop sddm.service
pulse_pid=$(pgrep -u igneel pulseaudio)
pipewire_pid=$(pgrep -u igneel pipewire-media)
kill $pulse_pid
kill $pipewire_pid

killall kwin
killall plasmashell

## Uncomment the following line if you use GDM
#killall gdm-x-session

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
sleep 2

modprobe -r nvidia-drm
modprobe -r nvidia-uvm
modprobe -r snd_hda_intel
modprobe -r i2c_nvidia_gpu
modprobe -r nvidia

sleep 2

# Unbind the GPU from display driver
virsh nodedev-detach pci_0000_01_00_0  #Replace numbers with your specific pci id. Use lspci -nnk
virsh nodedev-detach pci_0000_01_00_1  # This one too

# Load VFIO Kernel Module  
modprobe vfio-pci  
modprobe vfio
modprobe vfio_iommu_type1
