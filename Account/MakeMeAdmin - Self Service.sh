#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	Type: SELF SERVICE
#
#	Allows logged in user to promote their account to the local admin group from Self Service.
#	After 1 minute the account will be removed from the local admin group and converted back to
#	a standard user.
#
# VERSION
#
#	- 1.2
#
# CHANGE HISTORY
#
# 	- Created script - 1/5/2021 (1.0)
#	- Fixed the logged in user variable by removing python command (1.1) - 1/11/22
#	- Cleaned up script (1.2) - 6/24/22
#
####################################################################################################


##################################################################
## script variables
##################################################################

date=$(date +"%m-%d-%Y %H:%M:%S")
user=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
fullName=$(finger | grep "$user" | sed -n 1p | awk '{print $2,$3}')
computer=$(hostname)
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/private/var/tmp/ag_icon.png"


##################################################################
## script functions
##################################################################

function demoteUser ()
{
	/usr/sbin/dseditgroup -o edit -d $user -t user admin
}

function promoteUser () 
{
	/usr/sbin/dseditgroup -o edit -a $user -t user admin
}

function userInfo ()
{
	separator

	echo "Date: $date"

	echo "Name: $fullName ($user)"

	echo "Computer: $computer"

	separator
}

function separator ()
{
	echo "###################################################"

}

function jamfWindow ()
{

	"$jamfHelper" -windowType "hud" -title "Local Administrator Access" -heading "Admin Rights Enabled" -description "These rights will expire in:" -timeout 60 -countdown -countdownPrompt "" -alignCountdown right -icon "$icon" -windowPosition "lr" -lockHUD /dev/null 2>&1 &

	promoteUser

	sleep 60
    
    demoteUser

}

function appHistory ()
{

	echo "APPLICATION HISTORY"

    separator

	logDate=$(date +"%Y-%m-%d")
	
    viewAppLog=$(grep -ai -C 2 "$logDate" /Library/Receipts/InstallHistory.plist | awk '{print $1}' | sed 's/<date>/Date: /g ; s/<string>/App: /g ; /displayName/d ; /--/d ; /<key>/d ; /<dict>/d ; s/<\/date>//g ; s/<\/string>//g')

    echo "$viewAppLog"
    
    separator

}

function sudoHistory ()
{
    
    echo "SUDO HISTORY"

	separator
    
    viewSudoLog=$(cat ~/.bash_history | grep "sudo")
    
    echo "$viewSudoLog"
    
    separator

}

function bashHistory ()
{
    
    echo "BASH HISTORY"
    
	separator
    
    viewBashLog=$(cat ~/.bash_history)
    
    echo "$viewBashLog"
    
    separator

}

function cleanUp ()
{

	rm -rf "$icon"
    
}

function finalCheck ()
{

	# Get admin group membership
	adminGroup=$(dscl . -read /Groups/admin GroupMembership | grep -o "$user")

	# Checks to see if user is in the local admin group
	if [ "$user" = "$adminGroup" ]; then

		echo "LOCAL ADMIN GROUP CHECK"
        
		separator
        
        echo "- $user is a member of the local admin group"
        
        demoteUser

		echo "RESULT: $user was removed from group"
        
		separator

	else

		echo "LOCAL ADMIN GROUP CHECK"
        
		separator
        
        echo "RESULT: $user is NOT a member"
        
		separator

	fi
    
}


##################################################################
## main script
##################################################################

echo ""

# Checks to see if local administrator support account is logged in
if [ "$user" = "macadmin" ]; then

	separator
    
    echo "macadmin logged in: Yes"
    
    rm -rf "$icon"

	separator

	echo "RESULT: Exit script, cannot be ran from local administrator support account"

	separator

	exit 1

else
	
	separator
    
	echo "macadmin logged in: No"
    
    jamfWindow
    
    userInfo
    
    appHistory
    
    sudoHistory
    
    bashHistory
    
    cleanUp
    
    finalCheck
	
fi


exit 0