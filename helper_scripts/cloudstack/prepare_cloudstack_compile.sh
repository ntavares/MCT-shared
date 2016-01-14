#!/bin/bash

# Defaults
GIT_REPO=https://github.com/apache/cloudstack.git

# Script to prepare source for Apache CloudStack compile
HELPERSCRIPTS=$(dirname $(readlink -f $0))

[ "$HELPERSCRIPTS/config" ] && . "$HELPERSCRIPTS/config"

# Get source
BASEDIR=/data/git/${HOSTNAME}
MYDIR=$(pwd -P)

install_pkg() {
	NAME=$*
	yum install -y ${NAME}
	if [ "$?" -ne "0" ]
	then
		echo Package Installation Failed exiting
		exit 1
	fi
}

mkdir -p ${BASEDIR}
cd ${BASEDIR}
if [ ! -d "cloudstack/.git" ]; then
  echo "No git repo found, cloning Apache CloudStack"
  git clone $GIT_REPO cloudstack
  echo "Please use 'git checkout' to checkout the branch you need."
else
  echo "Git Apache CloudStack repo already found"
fi
cd cloudstack

# Check VHD-UTIL
if [ ! -f "scripts/vm/hypervisor/xenserver/vhd-util" ]; then
  echo "Fetching vhd-util.."
  cd scripts/vm/hypervisor/xenserver
  wget http://download.cloud.com.s3.amazonaws.com/tools/vhd-util
  cd $BASEDIR/cloudstack
fi

# Set MVN compile options
export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=512m -Xdebug -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n -Djava.net.preferIPv4Stack=true"
pwd
echo "Done."
