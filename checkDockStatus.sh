#!/bin/bash
#
# Script to check and keep looping till the Dock is loaded
# This can be used to launch or execute app or script after the Dock loads.
#
#
dockStatus=$(pgrep -x Dock)
echo "Waiting for Dock to launch"
while [[ "$dockStatus" == "" ]]
do
	echo "Dock is not loaded. Waiting"
	sleep 5
	dockStatus=$(pgrep -x Dock)
done
sleep 5
loggedinUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
echo "Dock loaded with $dockStatus for user $loggedinUser"
#
# Add your scripts or commands here to execute after the Dock is loaded

exit 0
