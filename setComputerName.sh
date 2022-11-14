#!/bin/bash
#
# Set ComputerName as $username-$serialnumber.
# Karthikeyan M
#

serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}') 
loggedinuser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )   #Current Logged in User.
name=$loggedinuser-$serialNumber   
scutil --set HostName $name
scutil --set LocalHostName $name
scutil --set ComputerName $name

## You can also use Jamf binary to set ComputerName in Jamf
#sudo jamf setComputerName -name $name