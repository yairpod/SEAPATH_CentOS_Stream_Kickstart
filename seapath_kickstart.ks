# Installation process
text
reboot
cdrom

# localization
lang en_US
keyboard --xlayouts='us'
timezone America/New_York --utc


# System bootloader configuration
bootloader --append="quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M  console=ttyS0,115200 console=tty0 efi=runtime ipv6.disable=1"

# Disks and partitions
# UPDATE: Change device path for your correct installation disk
ignoredisk --only-use=/dev/sda
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel

# Disk partitioning information
reqpart --add-boot
# UPDATE: Change device path for your correct installation disk
part pv.0 --fstype=lvmpv --ondisk=/dev/sda  --size=20992
part /boot/efi --fstype=efi --ondisk=/dev/sda --size=512 --asprimary
volgroup vg1 --pesize=4096 pv.0
logvol / --vgname=vg1 --name=vg1-root --fstype=ext4 --size=15360
logvol /var/log --vgname=vg1 --name=vg1-varlog --fstype=ext4 --size=5120
logvol swap --vgname=vg1 --name=vg1-swap --fstype=swap --size=500


# Network information
# UPDATE: change device name and static IP to your correct settings (gateway and nameserver might also be needed)
network --device=enp1s0 --bootproto=static --ip=10.0.0.2 --netmask=255.255.255.255 --gateway=10.0.0.1

# Do not configure the X Window System
skipx

# system services 
services --disabled=corosync,pacemaker
services --enabled=openvswitch

# Users
# UPDATE: The password is "toto" for all users
user --uid=1006 --gid=1006 --groups=wheel --name=virtu --iscrypted --password="$6$BZGBti/HRUWlyHhY$8zI5CFPcuBJw7pKupU4d9QLTqphBDyDpkW8zMySquiKO/qcRZoEcqvCJraJXJ5y0sdNdJ2vHb6.z/UvvLJSrM/"

user --uid=1005 --gid=1005 --groups=wheel,haclient --name=ansible --iscrypted --password="$6$BZGBti/HRUWlyHhY$8zI5CFPcuBJw7pKupU4d9QLTqphBDyDpkW8zMySquiKO/qcRZoEcqvCJraJXJ5y0sdNdJ2vHb6.z/UvvLJSrM/"

user --uid=902 --gid=902  --name=Centos-snmp

rootpw  --iscrypted $6$2Aj/yELlJst1TZMM$3JVT2YYjrbMpNGoHs.2O.SvcbtGSZqQvz5Ot5CdDmU/IsRFASnSqmlvS8bg8eGoOHmQ5i7dak0VWQWtziqYjh0


# ssh keys
# UPDATE: input your ssh-keys for
sshkey --username=virtu "ssh-rsa XXX"
sshkey --username=ansible "ssh-rsa XXX"
sshkey --username=root "ssh-rsa XXX"

# adding needed repositories

# CentOS addons
repo --name=HighAvailability --mirrorlist=https://mirrors.centos.org/metalink?repo=centos-highavailability-$stream&arch=$basearch&protocol=https,http --install

repo --name=Realtime --mirrorlist=https://mirrors.centos.org/metalink?repo=centos-rt-$stream&arch=$basearch&protocol=https,http --install

repo --name=CentOS-NFV --mirrorlist=https://mirrors.centos.org/metalink?repo=centos-nfv-$stream&arch=$basearch&protocol=https,http --install

# Docker
repo --name=Docker --baseurl=https://download.docker.com/linux/centos/9/x86_64/stable/ --install

# Fedora epel
repo --name=fedora_epel --baseurl=https://dl.fedoraproject.org/pub/epel/9/Everything/x86_64/ --install --cost=2


# OpenVSwitch
repo --name=rdo-release --mirrorlist=https://mirrors.centos.org/metalink?repo=centos-cloud-sig-openstack-yoga-9-stream&arch=x86_64 --install --cost=3

repo --name=centos-nfv-sig-openvswitch --mirrorlist=https://mirrors.centos.org/metalink?repo=centos-nfv-sig-openvswitch-2-9-stream&arch=x86_64 --install --cost=4

# Ceph
repo --name=Ceph_x86 --baseurl=https://mirror.stream.centos.org/SIGs/9-stream/storage/x86_64/ceph-pacific/ --install --cost=5


%packages
linux-firmware
microcode_ctl
at
audispd-plugins
audit
bridge-utils
ca-certificates
chrony
curl
docker-ce
docker-ce-cli
containerd.io
pcp-system-tools
gnupg
hddtemp
irqbalance
jq
lbzip2
linuxptp
net-tools
openssh-server
edk2-ovmf
python3-dnf
python3-cffi
python3-setuptools
net-snmp
net-snmp-utils
sudo
sysfsutils
syslog-ng
sysstat
vim
wget
rsync
pciutils
conntrack-tools

busybox
python-gunicorn
ipmitool
nginx
ntfs-3g
python3-flask-wtf
corosync
pacemaker
openvswitch

kernel-rt
grubby
kernel-rt-kvm
qemu-kvm

ceph
ceph-base
ceph-common
ceph-mgr
ceph-mgr-diskprediction-local
ceph-mon
ceph-osd
libcephfs2
libvirt
libvirt-daemon
libvirt-daemon-driver-storage-rbd
python3-ceph-argparse
python3-cephfs
tuna

tuned
tuned-profiles-nfv
tuned-profiles-realtime

virt-install

pcs
pcs-snmp

systemd-networkd
systemd-resolved
systemd-timesyncd

#for crmsh build
@development

#libvirt-clients
#docker-compose
#lm-sensors

@virtualization-hypervisor

%end

# additional file changes
%post 
cat <<EOF > /etc/motd
 ____  _____    _    ____   _  _____ _   _
/ ___|| ____|  / \  |  _ \ / \|_   _| | | |
\___ \|  _|   / _ \ | |_) / _ \ | | | |_| |
 ___) | |___ / ___ \|  __/ ___ \| | |  _  |
|____/|_____/_/   \_\_| /_/   \_\_| |_| |_|
EOF

cat <<EOF > /tmp/Docker_gpg
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFit5IEBEADDt86QpYKz5flnCsOyZ/fk3WwBKxfDjwHf/GIflo+4GWAXS7wJ
1PSzPsvSDATV10J44i5WQzh99q+lZvFCVRFiNhRmlmcXG+rk1QmDh3fsCCj9Q/yP
w8jn3Hx0zDtz8PIB/18ReftYJzUo34COLiHn8WiY20uGCF2pjdPgfxE+K454c4G7
gKFqVUFYgPug2CS0quaBB5b0rpFUdzTeI5RCStd27nHCpuSDCvRYAfdv+4Y1yiVh
KKdoe3Smj+RnXeVMgDxtH9FJibZ3DK7WnMN2yeob6VqXox+FvKYJCCLkbQgQmE50
uVK0uN71A1mQDcTRKQ2q3fFGlMTqJbbzr3LwnCBE6hV0a36t+DABtZTmz5O69xdJ
WGdBeePCnWVqtDb/BdEYz7hPKskcZBarygCCe2Xi7sZieoFZuq6ltPoCsdfEdfbO
+VBVKJnExqNZCcFUTEnbH4CldWROOzMS8BGUlkGpa59Sl1t0QcmWlw1EbkeMQNrN
spdR8lobcdNS9bpAJQqSHRZh3cAM9mA3Yq/bssUS/P2quRXLjJ9mIv3dky9C3udM
+q2unvnbNpPtIUly76FJ3s8g8sHeOnmYcKqNGqHq2Q3kMdA2eIbI0MqfOIo2+Xk0
rNt3ctq3g+cQiorcN3rdHPsTRSAcp+NCz1QF9TwXYtH1XV24A6QMO0+CZwARAQAB
tCtEb2NrZXIgUmVsZWFzZSAoQ0UgcnBtKSA8ZG9ja2VyQGRvY2tlci5jb20+iQI3
BBMBCgAhBQJYrep4AhsvBQsJCAcDBRUKCQgLBRYCAwEAAh4BAheAAAoJEMUv62ti
Hp816C0P/iP+1uhSa6Qq3TIc5sIFE5JHxOO6y0R97cUdAmCbEqBiJHUPNQDQaaRG
VYBm0K013Q1gcJeUJvS32gthmIvhkstw7KTodwOM8Kl11CCqZ07NPFef1b2SaJ7l
TYpyUsT9+e343ph+O4C1oUQw6flaAJe+8ATCmI/4KxfhIjD2a/Q1voR5tUIxfexC
/LZTx05gyf2mAgEWlRm/cGTStNfqDN1uoKMlV+WFuB1j2oTUuO1/dr8mL+FgZAM3
ntWFo9gQCllNV9ahYOON2gkoZoNuPUnHsf4Bj6BQJnIXbAhMk9H2sZzwUi9bgObZ
XO8+OrP4D4B9kCAKqqaQqA+O46LzO2vhN74lm/Fy6PumHuviqDBdN+HgtRPMUuao
xnuVJSvBu9sPdgT/pR1N9u/KnfAnnLtR6g+fx4mWz+ts/riB/KRHzXd+44jGKZra
IhTMfniguMJNsyEOO0AN8Tqcl0eRBxcOArcri7xu8HFvvl+e+ILymu4buusbYEVL
GBkYP5YMmScfKn+jnDVN4mWoN1Bq2yMhMGx6PA3hOvzPNsUoYy2BwDxNZyflzuAi
g59mgJm2NXtzNbSRJbMamKpQ69mzLWGdFNsRd4aH7PT7uPAURaf7B5BVp3UyjERW
5alSGnBqsZmvlRnVH5BDUhYsWZMPRQS9rRr4iGW0l+TH+O2VJ8aQ
=0Zqq
-----END PGP PUBLIC KEY BLOCK-----
EOF

echo "EDITOR=vim" >> /etc/environment
echo "SYSTEMD_EDITOR=vim" >> /etc/environment
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
rpm -import /tmp/Docker_gpg

echo "Defaults:ansible !requiretty" >> /etc/sudoers
echo "ansible    ALL=NOPASSWD:EXEC:SETENV: /bin/sh" >> /etc/sudoers
echo "ansible    ALL=NOPASSWD: /usr/bin/rsync" >> /etc/sudoers
echo "ansible    ALL=NOPASSWD: /usr/local/bin/crm" >> /etc/sudoers
echo "ansible    ALL=NOPASSWD: /usr/bin/ceph" >> /etc/sudoers

echo "virtu   ALL=NOPASSWD: ALL" >> /etc/sudoers

cat <<EOF > /etc/profile.d/custom-path.sh
PATH=$PATH:/usr/local/bin/
EOF

git clone https://github.com/ClusterLabs/crmsh.git /tmp/crmsh
cd /tmp/crmsh 
./autogen.sh
./configure
make
make install
mkdir -p  /var/log/crmsh/

grubby --set-default-index=0

%end
