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
