#!/bin/bash

sed -i 's,/archive.ubuntu.com/ubuntu,/mirror.nl.leaseweb.net/ubuntu,g' /etc/apt/sources.list
#apt-get update

# FIX Ubuntu stupidity
echo "hostname \$new_host_name" > /etc/dhcp/dhclient-exit-hooks.d/sethostname

# Disable apparmor
apt-get -y remove app-armor
dpkg --purge apparmor
#apt-get install linux-image-generic-lts-trusty

# Enable root password login
sed -i 's,^PermitRootLogin .*$,PermitRootLogin yes,g' /etc/ssh/sshd_config
service ssh restart

# Install dependencies for KVM on Cloudstack
sleep 5
#yum -y install http://mirror.karneval.cz/pub/linux/fedora/epel/epel-release-latest-7.noarch.rpm
#yum -y install qemu-kvm libvirt libvirt-python net-tools bridge-utils vconfig setroubleshoot virt-top virt-manager openssh-askpass wget vim
#yum --enablerepo=epel -y install sshpass
apt-get -y install qemu-kvm libvirt0 python-libvirt net-tools bridge-utils vlan virt-top virt-manager ssh-askpass wget vim sshpass nfs-common rpcbind git

# TODO - Enable rpbind for NFS
#systemctl enable rpcbind
#systemctl start rpcbind

# NFS to mct box
mkdir -p /data
mount -t nfs 192.168.22.1:/data /data
echo "192.168.22.1:/data /data nfs rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0" >> /etc/fstab

# Enable nesting
echo "options kvm_intel nested=1" >> /etc/modprobe.d/kvm-nested.conf

# Cloudstack agent.properties settings
cp -pr /etc/cloudstack/agent/agent.properties /etc/cloudstack/agent/agent.properties.orig
# Add these settings (before adding the host)
# libvirt.vif.driver=com.cloud.hypervisor.kvm.resource.OvsVifDriver
# network.bridge.type=openvswitch
#echo "libvirt.vif.driver=com.cloud.hypervisor.kvm.resource.OvsVifDriver" >> /etc/cloudstack/agent/agent.properties
#echo "network.bridge.type=openvswitch" >> /etc/cloudstack/agent/agent.properties
echo "guest.cpu.mode=host-model" >> /etc/cloudstack/agent/agent.properties

# Set the logging to DEBUG
sed -i 's/INFO/DEBUG/g' /etc/cloudstack/agent/log4j-cloud.xml

# Libvirtd parameters for Cloudstack
echo 'listen_tls = 0' >> /etc/libvirt/libvirtd.conf
echo 'listen_tcp = 1' >> /etc/libvirt/libvirtd.conf
echo 'tcp_port = "16509"' >> /etc/libvirt/libvirtd.conf
echo 'mdns_adv = 0' >> /etc/libvirt/libvirtd.conf
echo 'auth_tcp = "none"' >> /etc/libvirt/libvirtd.conf

# qemu.conf parameters for Cloudstack
sed -i -e 's/\#vnc_listen.*$/vnc_listen = "0.0.0.0"/g' /etc/libvirt/qemu.conf

# Create new initrd to disable co-mounts
#sed -i "/JoinControllers/c\JoinControllers=''" /etc/systemd/system.conf
#new-kernel-pkg --mkinitrd --install `uname -r`

# TODO - Network
# Device

# Allow everybody in
git clone https://git.ocom.com/scm/infracloud/pubkeys.git
cat pubkeys/* >> /root/.ssh/authorized_keys

# Reboot
reboot

