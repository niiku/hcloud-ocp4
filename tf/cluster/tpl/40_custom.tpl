#!/bin/sh
exec tail -n +3 $0
menuentry 'Install Red Hat Enterprise Linux CoreOS' --class fedora --class gnu-linux --class gnu --class os {
	linux /boot/rhcos-installer-kernel rd.neednet=1 coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=http://${ignition_hostname}/rhcos-metal-bios.raw.gz coreos.inst.ignition_url=http://${ignition_hostname}/${server_role}.ign
	initrd /boot/rhcos-initramfs.img
}