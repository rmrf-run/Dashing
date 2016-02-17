#!/usr/bin/env bash
#
#
# Getting only memory used percentage to feed into dashing
#
#
#Get total memory available on machine
totalMem=$(free -m | grep Mem | awk '{ print $2 }')
freeMem=$(free -m | grep Mem | awk '{ print $7 }')
echo $freeMem
exit 0
