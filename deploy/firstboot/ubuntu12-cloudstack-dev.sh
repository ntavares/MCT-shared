#!/bin/bash

sed -i 's,/archive.ubuntu.com/ubuntu,/mirror.nl.leaseweb.net/ubuntu,g' /etc/apt/sources.list
#apt-get update

# FIX Ubuntu stupidity
echo "hostname \$new_host_name" > /etc/dhcp/dhclient-exit-hooks.d/sethostname

# Disable apparmor
apt-get -y remove app-armor

# Enable root password login
sed -i 's,^PermitRootLogin .*$,PermitRootLogin yes,g' /etc/ssh/sshd_config
service ssh restart


# Prepare bare box to compile CloudStack and run management server
sleep 5
export DEBIAN_FRONTEND=noninteractive
apt-get -y install maven tomcat6 mkisofs python-paramiko \
    jsvc jsvc libws-commons-util-java \
    genisoimage gcc python python-mysqldb \
    openssh-client \
    wget git python-ecdsa bzip2 python-setuptools \
    libpython-dev vim nfs-common screen \
    ssh-askpass \
    openjdk-6-jdk \
    rubygems-integration \
    netcat python-mysql.connector \
    python-crypto \
    python-nose \
    sshpass mysql-server

#####################################################################

echo "JAVA_OPTS=\"-Djava.awt.headless=true -Dfile.encoding=UTF-8 -server -Xms1536m -Xmx3584m -XX:MaxPermSize=256M\"" >> /etc/default/tomcat6
/etc/init.d/tomcat6 restart

echo "[server]
max_allowed_packet=64M" >> /etc/mysql/conf.d/bubble.cnf
#systemctl start mariadb.service
#systemctl enable mariadb.service

#systemctl stop firewalld.service
#systemctl disable firewalld.service

mkdir -p /data
mount -t nfs 192.168.22.1:/data /data
echo "192.168.22.1:/data /data nfs rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0" >> /etc/fstab

mkdir -p /data/git
cd /data/git
cd /root

wget https://raw.githubusercontent.com/remibergsma/dotfiles/master/.screenrc

curl "https://bootstrap.pypa.io/get-pip.py" | python
pip install cloudmonkey

#easy_install nose
#easy_install pycrypto

# Reboot
reboot
