#!/bin/bash
#Check memory to feed into sensu to get into dashing
totalMem=$(free -m | grep Mem | awk '{ print $2 }')
freeMem=$(free -m | grep Mem | awk '{ print $7 }')
echo $totalMem
exit 0
