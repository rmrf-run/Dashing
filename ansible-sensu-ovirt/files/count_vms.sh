#!/bin/bash
#Count the number of running VMs on the host
numVMs=$(ps ax | grep /usr/libexec/qemu-kvm | wc -l)
numVMs=$(($numVMs - 1))
echo $numVMs
exit 0
