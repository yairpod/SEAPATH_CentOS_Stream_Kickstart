# SEAPATH_CentOS_Stream_Kickstart
Reference Kickstart file for the installation of CentOS Stream for the LF SEAPATH project.
CentOS Stream uses the Anaconda Installer which allows for automation and unattended installations via kickstart files.
See more at: https://pykickstart.readthedocs.io/en/latest/

## Customization
Since the kickstart file defines installation parameters and each installation setup is different customization is recommended, Moreover since it includes local passwords and ssh keys some items are mandatory.

### Mandatory
**change the authorized_keys files (user and root) with your own**
Edit the seapath_kickstart.ks file and change the lines:
```
sshkey --username=virtu "ssh-rsa XXX"
sshkey --username=ansible "ssh-rsa XXX"
sshkey --username=root "ssh-rsa XXX"
```
Replacing the quoted section with the ssh key of your choice.

### Optional

The default password for root and unprivileged users is "toto". To change it,
replace [rootpw](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#rootpw) with encrypted root password.

In the lines beginning with `user` change the value of `--password=` to [encrypted passwords](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#user) of your choice.

**Depending on your network configuration**
Replace network device, ip and gateway and the `network` line.

**Depending on your Disk configuration**
Replace The installation disk device in lines:
```
ignoredisk --only-use=/dev/sda
part pv.0 --fstype=lvmpv --ondisk=/dev/sda  --size=20992
part /boot/efi --fstype=efi --ondisk=/dev/sda --size=512 --asprimary
```
Remove the line starting with `ignoredisk` if you wish to install on more then one disk.

Please consult the kickstart Documentation on https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html

## Usage
To install an image with the Kickstart file download an installation ISO such as from:
https://centos.org/download/#centos-stream-9

Then you can either add the kickstart file to the ISO using the [mkksiso command](https://www.mankier.com/1/mkksiso).
Example:
```
mkksiso seapath_kickstart.ks CentOS-Stream-9-latest-x86_64-dvd1.iso seapath.iso
```
Or configure your server to use the kickstart file via network.

## Running SEAPATH hosts as VMs
### Create ISOs
create_vm_isos.sh script contains mkkiso commands. Edit it and replace the

        sed 's/--ip=192.168.124.2/--ip=192.168.124.3/' seapath_kickstart.ks > kickstart_seapath_2.ks
        sed 's/--ip=192.168.124.2/--ip=192.168.124.4/' seapath_kickstart.ks > kickstart_seapath_3.ks

Lines with the IP address configured in seapath_kickstart.ks (this is setting IP address
for the 3 different hosts).

Then run

`create_vm_isos.sh rebuild`

### Creating VMs

If using NAT, create a libvirt network for 192.168.124.1:

	<network>
		<name>seapath-default</name>
		<forward mode='nat'/>
		<bridge name='virbr1' stp='on' delay='0'/>
		<mac address='52:54:00:73:d2:34'/>
		<ip address='192.168.124.1' netmask='255.255.255.0'>
		<dhcp> 
			<range start='192.168.124.20' end='192.168.124.254'/> 
		</dhcp> 
  		</ip>
	</network>

Then create the network:

	virsh net-define seapath-default.xml
	virsh net-autostart seapathdefault
	virsh net-start seapathdefault

Note:
	Had to change /etc/libvirt/network.conf to include firewall_backend = "nftables" 
	on RHEL-9.

For 3 VM cluster (where the 3 VMs are connected by bridges in a ring scheme),
setup the bridges.

Create bridges:

	ip link add br0 type bridge
	ip link add br1 type bridge
	ip link add br2 type bridge
	ip link set br0 up
	ip link set br1 up
	ip link set br2 up
	ip link set dev br0 mtu 9000
	ip link set dev br1 mtu 9000
	ip link set dev br2 mtu 9000

Add the bridges to libvirt. Create a file named net-bridge-0.xml:

	<network>
		<name>hostbridge0</name>
		<forward mode="bridge"/>
		<bridge name="br0"/>
	</network>

Create three of them and then run for each one:

	virsh --connect qemu:///system net-define ./net-bridge-0.xml
	virsh --connect qemu:///system net-start hostbridge0

### Create the VMs

Use 1 ISO and the 2 disks for each VM.
Use “vm_example.xml” as a template for the VM.

Modify the path to disks and the iso based on the VM.

For multi VM setups, connect one of the network card
to the default bridge and the other two to each corresponding bridge.
Then:

        # virsh define vm_example_modified.xml

Each VM has the following network cards:

	enp1s0 (main to communicate through ansible and NAT default bridge)
	enp2s0 (ring)
	enp3s0 (ring)

Boot each VM from ISO (the kickstart installation should be performed).

### Apply SEAPATH playbooks

#### Create Container to run Ansible 2.10

Clone the seapath ansible repository:

	# git clone https://github.com/seapath/ansible.git

Containerfile (in this git repository) contains instructions to create
a CentOS 9 based container. To build the container:

	# podman build --tag centos4seapath .

Then run the container (note: should modify /path/to/seapath-ansible-git/ and /home/user/,
the user which SSH keys were used to create the Seapath ISO files):

	# podman run --privileged --rm --mount type=bind,source=/path/to/seapath-ansible-git/,target=/root/ansible/ --mount type=bind,source=/home/user/.ssh/,target=/root/.ssh/ -it centos4seapath

Inside the container, cd to /root/ansible/, then run

	# ./prepare.sh

To pull dependencies necessary by the SEAPATH Ansible scripts.
