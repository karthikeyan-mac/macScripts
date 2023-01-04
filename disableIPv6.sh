#!/bin/sh
IFS=$'\n'
allPorts=`networksetup -listallnetworkservices | grep -v asterisk`
for port in $allPorts
do
	networksetup -setv6off "$port"
	echo "$port" IPv6 is Off
done
exit 0
