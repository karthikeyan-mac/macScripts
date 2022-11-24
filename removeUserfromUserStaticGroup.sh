#!/bin/bash
#
# Script to delete the user from User Static Group
# Karthikeyan
#
#

jamfUser="karthik_api"
jamfPass="yourPassword"
jamfUrl="https://karthikdev.jamfcloud.com" ### JSS URL https://yourcompanyname.domainname.com (without / in the end)
userNametobeRemoved="karthikeyan.m"   #username to remove
userStaticGroupID=1  # User Static Group ID

fetchJamfAPIToken() {
	
		authTokenJson=$(/usr/bin/curl -s -X POST -u "${jamfUser}:${jamfPass}" "${jamfUrl}/api/v1/auth/token")
		api_token=$(/usr/bin/plutil -extract "token" raw -expect "string" -o - - <<< "${authTokenJson}")
		#echo $api_token
}
fetchJamfAPIToken


response=$(curl -s --location --request PUT "${jamfUrl}/JSSResource/usergroups/id/${userStaticGroupID}" \
--header "Accept: application/xml" \
--header "Content-Type: application/xml" \
--header "Authorization: Bearer ${api_token}" \
--data-raw "<user_group><user_deletions><user><username>${userNametobeRemoved}</username></user></user_deletions></user_group>" \
--write-out '\n%{http_code}'
)

#echo "$response"

http_code=$(tail -n1 <<< "$response")  # get the last line
content=$(sed '$ d' <<< "$response")   # get all but the last 


#echo $http_code
#echo "$content"

if [[ $http_code == 201 ]]; then
	echo "Success with Status Code: ${http_code}"
	echo "Removed \"$userNametobeRemoved\" from the Static User Group"
	
else
	echo "API Failed with Status Code: ${http_code}"
	
	errorText=$(echo "$content" | awk 'NR==7')
	#echo $triMM
	echo "${errorText:3:${#errorText}-7}" 
fi