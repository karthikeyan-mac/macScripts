#!/bin/zsh
# Get the currently logged in user
# Jamf EA to report Nudge requiredMinimumOSVersion and userDeferrals from Nudge Plist
loggedInUser="$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )"
echo $loggedInUser
# Check for a logged in user and proceed with last user if needed
if [[ $loggedInUser == "" ]]; then
	# Set loggedInUser variable to the last logged in user
	loggedInUser=$( defaults read /Library/Preferences/com.apple.loginwindow lastUserName )
fi

nudgePlist="com.github.macadmins.Nudge.plist"

# Get the required minimum OS version from the plist
requiredMinimumOSVersion="$( defaults read /Users/$loggedInUser/Library/Preferences/$nudgePlist requiredMinimumOSVersion )"
userDeferrals="$( defaults read /Users/$loggedInUser/Library/Preferences/$nudgePlist userDeferrals )"
# Report info from nudge plist
echo "<result>MinOS: $requiredMinimumOSVersion - DefCount: $userDeferrals</result>"
# Output will be like "MinOS: 13.4 - DefCount:97"
