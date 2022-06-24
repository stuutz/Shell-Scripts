#!/bin/sh

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
# 	Type: POLICY
#
#	This script will do the following:
#	- Checks to see if the admin account is logged in
#	- Checks to see if the computer is bound to the domain
#	- Checks to see if the logged in user is a member of the AD group
#	- Removes logged in user from local admin group
#	- Adds/Removes computer from Static Computer Group in JAMF (using API) based on AD Group membership
#	- Will show/hide MakeMeAdmin Self Service policy based on Static Group membership
#
# VERSION
#
#	- 1.8
#
# CHANGE HISTORY
#
# 	- Created script - 5/11/20 (1.0)
#	- Rewrote script with functions and improved variable reporting - 7/16/20 (1.1)
#	- Commented out promote function replacing with addToStaticGroup/removeFromtStaticGroup - 1/4/21 (1.2)
#	- Fixed issue when searching AD group for user.  Added -o option to grep command to only find matching strings - 3/19/21 (1.3)
#	- Removed the JAMF Recon command for quicker policy completion - 8/3/21 (1.4)
#	- Made the network check function more accurate - 8/10/21 (1.5)
#	- Fixed a unary operator error in the domainStatus function - 9/14/21 (1.6)
#	- Fixed the logged in user variable by removing python command (1.7) - 1/11/22
#	- Cleaned up script (1.8) - 6/24/22
#
####################################################################################################


##################################################################
# Script variables (EDIT)
##################################################################

adGroup="AD-Group"
groupName="JAMF-Static-Group-Name"
groupID="JAMF-Static-Group-ID (ex: 460)"
domainURL=mycompany.com
domainName=MYCOMPANY

##################################################################
# Script variables
##################################################################

date=$(date +"%m-%d-%Y %H:%M:%S")
computer=$(hostname)
loggedInUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
userUID=$(id -u ${loggedInUser})
domain=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}' | sed -e 's/.corp//g' | tr '[:lower:]' '[:upper:]')
userAD=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}' | tr '[:lower:]' '[:upper:]')
userMacOS=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
fullName=$(finger | grep "$userMacOS" | sed -n 1p | awk '{print $2,$3}')
adGroupMembership=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" dscl /Active\ Directory/$domain/All\ Domains -read /Groups/$adGroup | grep -o "$userAD" | sed -e 's/GroupMembership://g;s/'$domain'\\//g;s/^[ \t]*//;s/[ \t]*$//' | sed -n 2p)

##################################################################
# Script functions (EDIT API INFO ONLY)
##################################################################

function demoteUser ()
{
	/usr/sbin/dseditgroup -o edit -d $userMacOS -t user admin
}

function addToStaticGroup ()
{

	## API login info
	apiuser="USERNAME"
	apipass='PASSWORD'
	jamfProURL="https://MYCOMPANY.jamfcloud.com"
	apiURL="JSSResource/computergroups/id/${groupID}"

	## XML header stuff
	xmlHeader="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"

	apiData="<computer_group><id>${groupID}</id><name>$groupName</name><computer_additions><computer><name>$computer</name></computer></computer_additions></computer_group>"

	curl -sSkiu ${apiuser}:${apipass} "${jamfProURL}/${apiURL}" \
		-H "Content-Type: text/xml" \
		-d "${xmlHeader}${apiData}" \
		-X PUT  > /dev/null

}

function removeFromStaticGroup ()
{

	## API login info
	apiuser="USERNAME"
	apipass='PASSWORD'
	jamfProURL="https://MYCOMPANY.jamfcloud.com"
	apiURL="JSSResource/computergroups/id/${groupID}"

	## XML header stuff
	xmlHeader="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"

	apiData="<computer_group><id>${groupID}</id><name>$groupName</name><computer_deletions><computer><name>$computer</name></computer></computer_deletions></computer_group>"

	curl -sSkiu ${apiuser}:${apipass} "${jamfProURL}/${apiURL}" \
		-H "Content-Type: text/xml" \
		-d "${xmlHeader}${apiData}" \
		-X PUT  > /dev/null

}

function userInfo ()
{

	echo ""

	separator

	echo "Date: $date"

	echo "Name: $fullName ($userMacOS)"

	echo "Computer: $computer"

	separator
}

function separator ()
{
	echo "###################################################"

}

function adminCheck ()
{
if [ "$userMacOS" = "macadmin" ]; then
	
	echo "CHECK 1: Admin Support Account: Yes"

	separator

	echo "RESULT: Exit script, cannot be ran from local administrator support account"

	separator

	exit 1

else
	
	echo "CHECK 1: Admin Support Account: No"
	
fi
}

function networkCheck ()
{
domainStatus=$(odutil show nodenames | grep "/Active Directory/${domainName}/${domainURL}" | grep "Online" | awk '{print $3}')

if [ "$domainStatus" = "Online" ]; then

	echo "CHECK 2: Domain Bound: Yes ($domain)"

else

	echo "CHECK 2: Domain Bound: No"

	removeFromStaticGroup

	separator

	echo "RESULT: FAILED verifying AD group membership, removed computer from static group"

	separator

	exit 1

fi
}

function adGroupCheck ()
{
if [ "$userAD" = "$adGroupMembership" ]; then
	
	echo "CHECK 3: AD Group Member: Yes"
	
	demoteUser

	addToStaticGroup

	separator

	echo "RESULT: Added computer to static group"

else

	echo "CHECK 3: AD Group Member: No"

	demoteUser

	removeFromStaticGroup

	separator

	echo "RESULT: Removed computer from static group"

fi
}

##################################################################
# main script
##################################################################

## Get user info
userInfo

## CHECK 1 - Check to see if local administrator support account is logged in
adminCheck

## CHECK 2 - Verify if domain is bound
networkCheck

## CHECK 3 - Promote/demote user from local admin group based on AD group membership
adGroupCheck

separator

exit 0

