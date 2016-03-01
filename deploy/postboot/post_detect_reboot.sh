#!/bin/bash

# We get this passed from the main script
NEWHOST=$1
echo "Note: ${NEWHOST}: Waiting for the VM to boot..."
# Wait until the VM is alive
while ! ping -w 1 -c1 ${NEWHOST} &>/dev/null; do : echo -n . ; sleep 1; done
echo "Note: ${NEWHOST}: Installing and configuring"
echo "Note: ${NEWHOST}: This will take some time. You may send this to the background."
while ping -w 1 -c1 ${NEWHOST} &>/dev/null; do : echo -n . ; sleep 1; done
echo "Note: ${NEWHOST}: Rebooting"
while ! ping -w 1 -c1 ${NEWHOST} &>/dev/null; do : echo -n . ; sleep 1; done
sleep 15
echo "Note: ${NEWHOST}: Ready for duty!"
