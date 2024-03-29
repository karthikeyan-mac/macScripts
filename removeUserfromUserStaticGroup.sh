#!/bin/bash
#
# Script to delete the user from User Static Group
# Karthikeyan
#
#

jamfUser="karthik_api"
jamfPass="yourPassword"
jamfUrl="https://karthikdev.jamfcloud.com" ### JSS URL https://yourcompanyname.domainname.com (without / in the end)
userStaticGroupID=1  # User Static Group ID
serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}') 

fetchJamfAPIToken() {
	
		if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
			api_token=$(/usr/bin/curl -X POST --silent -u "${jamfUser}:${jamfPass}" "${jamfUrl}/api/v1/auth/token" | python -c 'import sys, json; print json.load(sys.stdin)["token"]')
		else
			authTokenJson=$(/usr/bin/curl -s -X POST -u "${jamfUser}:${jamfPass}" "${jamfUrl}/api/v1/auth/token")
			api_token=$(/usr/bin/plutil -extract "token" raw -expect "string" -o - - <<< "${authTokenJson}")
		fi
		
}
fetchJamfAPIToken


fetchUserName() {
		response=$(curl -s --location --request GET "${jamfUrl}/JSSResource/computers/serialnumber/${serialNumber}" \
		--header 'Accept: application/xml, application/json' \
		--header 'Content-Type: application/xml' \
		--header "Authorization: Bearer ${api_token}")
		#echo $response
	
		userNametobeRemoved=$(echo $response | xmllint --xpath '/computer/location/username/text()' -) 
		echo "$userNametobeRemoved"
	
}
fetchUserName

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
