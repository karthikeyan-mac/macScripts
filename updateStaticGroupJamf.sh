#!/bin/bash
#
# Script to update (add/remove) the existing Computer Static Group from the list of serial numbers.
# Karthikeyan Marappan
# This script will read the serialNumberList file path with the list of serial numbers as a source list. 
# actionRequired - Values: ADD/REMOVE. Add will add the serial numnber
# I am not a expert scripter so open to ideas to improve it.
#
###################### UPDATE BELOW VARIABLES ################################
serialNumberList="/Users/karthikeyan.m/Desktop/sourceList.txt"
jamfUrl="https://yourinstance.jamfcloud.com/"            #JAMF URL
jamfUser="karthik_api"
jamfPass="api"      
staticGroupID=19            #Static Group ID #This ID can be found in address bar.
actionRequired="ADD"        #ADD for adding the computer to static group, REMOVE for deleting it
#############################################################################

countSuccess=0
countFailure=0
successSerial=()
failureSerial=()

# Check if file exits and not empty.
if [ ! -f $serialNumberList ]; then
    echo "Error: Source file does not exists."
    exit 1
elif [ ! -s $serialNumberList ]; then
    echo "Error: Source file is empty"
    exit 1
fi

# Check if mandatory varibles are not empty
if [ -z "$jamfUrl" ] || [ -z "$jamfUser" ] || [ -z "$jamfPass" ] || [ -z "$staticGroupID" ] || [ -z "$actionRequired" ]; then
    echo "Error: Variables empty"
    exit 1
fi

# Format the Jamf URL based on /
if [[ ${jamfUrl: -1} == "/" ]]; then
    jamfUrl=`echo "${jamfUrl}" | sed 's/.$//'`
fi 

# Decide the Action based on actionRequired variable,
if [[ $actionRequired == "ADD" ]]; then
    action="computer_additions"
elif [ $actionRequired == "REMOVE" ]; then
    action="computer_deletions"
else
    echo "Error: actionRequired variable is mandatory. ADD"
    exit 1
fi

## Request Bearer API Token
fetchJamfAPIToken() {
    authTokenJson=$(/usr/bin/curl -s -X POST -u "${jamfUser}:${jamfPass}" "${jamfUrl}/api/v1/auth/token")
    if [[ "$authTokenJson" == *"401"* ]]; then
        echo "Error: Verify Jamf Server URL and Credentials"
        exit 1
    fi
    api_token=$(/usr/bin/plutil -extract "token" raw -expect "string" -o - - <<< "${authTokenJson}")
    #echo $api_token
}

fetchJamfAPIToken

## Loop into the list from file.
for serialNumber in `cat "$serialNumberList"`; do
    response=$(curl -s --location --request PUT "${jamfUrl}/JSSResource/computergroups/id/${staticGroupID}" \
    --header "Accept: application/xml" \
    --header "Content-Type: application/xml" \
    --header "Authorization: Bearer ${api_token}" \
    --data-raw "
    <computer_group>
        <${action}>
            <computer>
                <serial_number>${serialNumber}</serial_number>
            </computer>
        </${action}>
    </computer_group>" \
    --write-out '\n%{http_code}' 
)
    http_code=$(tail -n1 <<< "$response")  # get the last line
    content=$(sed '$ d' <<< "$response")   # get all but the last 

    if [[ $http_code == 201 ]]; then
        countSuccess=$((countSuccess+1))
        successSerial+=($serialNumber)
        #echo "Success with Status Code: ${http_code}"
        #echo "Added - \"$serialNumber\" to the Static Group"        
    elif [[ $http_code == 409  ]]; then
        countFailure=$((countFailure+1))
        #echo "API Failed with Status Code: ${http_code}"
        #errorText=$(echo "$content" | awk 'NR==7')
        #echo "\"$serialNumber\" - ${errorText:3:${#errorText}-7}" 
        failureSerial+=($serialNumber)
        
    else
        echo "Error: Please verify the parameters like Static Group ID, JAMF URL and credentials"
        exit 1
    fi
done

echo "Success: ${countSuccess}"
echo "---------------------------------------"
for sSerial in "${successSerial[@]}"
do
    echo "${sSerial}"
done
echo "---------------------------------------"
echo "Failed: ${countFailure}"
echo "---------------------------------------"
for fSerial in "${failureSerial[@]}"
do
    echo "${fSerial}"
done