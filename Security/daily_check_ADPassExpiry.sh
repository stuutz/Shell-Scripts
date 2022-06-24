#!/bin/bash

####################################################################################################
# ABOUT THIS SCRIPT
#
# CREATED BY
# 
#	Brian Stutzman
#
# DESCRIPTION
#
# 	This script check the users AD password expiration.  If its less than 14 days from expiration
#	it will inform the user and give them the option to reset their password.
#
# VERSION
#
# 	1.7
#
####################################################################################################
# CHANGE HISTORY
#
# - Created script (1.0) - 9/23/19
# - Added elif statement (1.1) - 2/21/20
# - Added a networkCheck function, ensures script only runs when domain is connected (1.3) - 7/1/20
# - Modified the networkCheck function to report domain status more accurately (1.4) - 7/24/20
# - Added icon path for macOS 11.0 in the JAMF Helper window (1.5) - 10/13/20
# - Fixed the logged in user variable by removing python command (1.6) - 1/11/22
# - Cleaned up script (1.7) - 6/24/22
#
####################################################################################################

##################################################################
## Script variables (edit)
##################################################################

domainURL=mycompany.com
domainName=MYCOMPANY

##################################################################
## Script functions
##################################################################

function networkCheck ()
{
echo ""
echo "Script >>> =================================================="
echo "Script >>> Configuring Computer - SCRIPT"
echo "Script >>> =================================================="
domainStatus=$(odutil show nodenames | grep "/Active Directory/${domainName}" | sed -n 1p | awk '{print $3}')

if [[ $domainStatus = "Online" ]]; then

	echo "Script >>> Domain Connected"
	echo "Script >>> =================================================="
	
else

	if [[ $domainStatus = "Offline" ]]; then
	
		echo "Script >>> Domain Offline"
		echo "Script >>> EXIT SCRIPT"
		echo "Script >>> =================================================="
		echo "Script >>> =================================================="
		
		exit 1
	
		elif [[ $domainStatus = "" ]]; then
	
			echo "Script >>> Domain Not Found"
			echo "Script >>> EXIT SCRIPT"
			echo "Script >>> =================================================="
			echo "Script >>> =================================================="
		
			exit 1

	else
	
		echo "Script >>> Domain Not Connected"
		echo "Script >>> EXIT SCRIPT"
		echo "Script >>> =================================================="
		echo "Script >>> =================================================="
		
		exit 1
	
	fi

fi
}


function adPWCheck ()
{
echo "Script >>> =================================================="
echo "Script >>> CHECKING USER PW EXPIRATION"
echo "Script >>> =================================================="

currentUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
fullName=$(finger | grep "$currentUser" | sed -n 1p | awk '{print $2,$3}')
domain=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')
osVersion=$(sw_vers -productVersion | cut -c 1-5)
osVersionNEW=$(sw_vers -productVersion | cut -c 1-2)
# Get window icon based on macOS version
if [ "$osVersion" = "10.13" ] || [ "$osVersion" = "10.14" ]; then
icon="/Applications/Utilities/Keychain Access.app/Contents/Resources/AppIcon.icns"
fi
if [ "$osVersion" = "10.15" ] || [ "$osVersionNEW" = "11" ]; then
icon="/System/Applications/Utilities/Keychain Access.app/Contents/Resources/AppIcon.icns"
fi

# User Check
echo "Script >>> CHECK 1 - SEARCH FOR USER"

if [ "$domain" = "$domainURL" ]; then
	
	echo "Script >>> User: $fullName ($currentUser)"
	
	echo "Script >>> PASSED!"
	
	domainPath="/Active Directory/${domainName}/All Domains"
	
	# Change daysPWValid below to a days value that your passwords need to change. For example, if they expire after 60 days, put in 60. If 90 days, put in 90, etc.
	daysPWValid="90"
	
	secsPWValid=$((60*60*24*daysPWValid))
	
	timeNow=$(date +"%s")

else

	echo "Script >>> AD Server not found"

	echo "Script >>> FAILED!"

fi

echo "Script >>> CHECK 2 - PASSWORD EXPIRATION"

# Gets the raw last password set value from AD
lastPWChangeRaw=$(dscl "$domainPath" read /Users/${currentUser} SMBPasswordLastSet | cut -d' ' -f2)

# Does calculation to get some values we need on the next password change + how many days left
if [ "$lastPWChangeRaw" != "" ]; then

	lastPWChangeTrue=$((lastPWChangeRaw/10000000-11644473600))
		
	nextPWChangePlusTime=$((lastPWChangeTrue+secsPWValid))
		
	nextPWChange=$(date -jf "%s" "$nextPWChangePlusTime" +"%m-%d-%Y %r")
		
	daysToChange=$((((nextPWChangePlusTime-timeNow))/60/60/24))
	
	echo "Script >>> Expires: $daysToChange days"
		
	if [ "$daysToChange" -lt "15" ]; then
    
    	echo "Script >>> Prompting user to change (< 14 days)"
		
		jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
		
		userChoice=$("$jamfHelper" -windowType "hud" -heading "Password Expiration" \
		-description "You have "$daysToChange" days left. \
		

To avoid account login issues please take a moment to reset your password." -button1 "Reset" -button2 "Cancel" -icon "$icon" -windowPosition "lr" -defaultButton 0 -lockHUD)
	
		if [ "$userChoice" == "0" ]; then
			
			echo "Script >>> User Clicked Reset"

			#sudo -iu "$currentUser" sh /Library/Scripts/ChangePassword.sh
			
			osascript -e '
			tell application "Finder" to open file "Accounts.prefpane" of (path to system preferences)
			tell application "System Events"
					tell application process "System Preferences"
						delay 1
						click button "Change Password…" of tab group 1 of window "Users & Groups"
					end tell
			end tell
			'

		elif [ "$userChoice" == "2" ]; then

			echo "Script >>> User Clicked Cancel"

		fi

	fi

else

		echo "Script >>> No last password set date was found."

fi

echo "Script >>> =================================================="
echo "Script >>> =================================================="
}


##################################################################
## Main script
##################################################################

networkCheck

adPWCheck
