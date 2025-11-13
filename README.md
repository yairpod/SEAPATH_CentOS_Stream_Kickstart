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

## Usage:
To install an image with the Kickstart file download an installation ISO such as from:
https://centos.org/download/#centos-stream-9
Then you can either add the kickstart file to the ISO using the [mkksiso command](https://www.mankier.com/1/mkksiso).
Example:
```
mkksiso seapath_kickstart.ks CentOS-Stream-9-latest-x86_64-dvd1.iso seapath.iso
```
Or configure your server to use the kickstart file via network.

