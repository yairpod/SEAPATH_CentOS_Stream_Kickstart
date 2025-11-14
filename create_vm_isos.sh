#! /usr/bin/bash
# This script is used to build 3 iso, one for each host
# and six disks, two per host 
# It requires: lorax

if [[ $1 == "rebuild" ]]; then
	cp seapath_kickstart.ks  ./kickstart_seapath_1.ks
	sed 's/--ip=192.168.124.2/--ip=192.168.124.3/' seapath_kickstart.ks > kickstart_seapath_2.ks
	sed 's/--ip=192.168.124.2/--ip=192.168.124.4/' seapath_kickstart.ks > kickstart_seapath_3.ks
fi

rm -f seapath-clone-ceph-1-clone-clone.qcow2 && qemu-img create -f qcow2 seapath-clone-ceph-1-clone-clone.qcow2 10737418240
rm -f seapath-clone-ceph-2-clone-clone.qcow2 && qemu-img create -f qcow2 seapath-clone-ceph-2-clone-clone.qcow2 10737418240
rm -f seapath-clone-ceph-3-clone-clone.qcow2 && qemu-img create -f qcow2 seapath-clone-ceph-3-clone-clone.qcow2 10737418240

rm -f seapath-1-Centos.qcow2 && qemu-img create -f qcow2 seapath-1-Centos.qcow2 109521666048
rm -f seapath-2-Centos.qcow2 && qemu-img create -f qcow2 seapath-2-Centos.qcow2 109521666048
rm -f seapath-3-Centos.qcow2 && qemu-img create -f qcow2 seapath-3-Centos.qcow2 109521666048

if [[ $1 == "rebuild" ]]; then
	rm -f seapath_fedora_1.iso && time mkksiso --debug --ks kickstart_seapath_1.ks CentOS-Stream-9-latest-x86_64-dvd1.iso  seapath_fedora_1.iso
	rm -f seapath_fedora_2.iso && time mkksiso --debug --ks kickstart_seapath_2.ks CentOS-Stream-9-latest-x86_64-dvd1.iso  seapath_fedora_2.iso
	rm -f seapath_fedora_3.iso && time mkksiso --debug --ks kickstart_seapath_3.ks CentOS-Stream-9-latest-x86_64-dvd1.iso  seapath_fedora_3.iso
fi
