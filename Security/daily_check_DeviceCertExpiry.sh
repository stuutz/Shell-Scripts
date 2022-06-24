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
# 	This script check the computers device certificate for expiration.  If its less than 14 days
#	from expiration it will inform the user and give them the option generate a new certificate.
#	It will also check for duplicate certificates.
#
# VERSION
# 
# 	1.7
#
####################################################################################################
# CHANGE HISTORY
#
# - Created script (1.0) - 9/23/19
# - Refined the device certificate function to add a duplicate checker and resolution (1.1) - 6/11/20
# - Run security binary as the user instead of root, reports certs accurately (1.2) - 6/30/20
# - Added a networkCheck function, ensures script only runs when domain is connected (1.3) - 7/1/20
# - Modified the networkCheck function to report domain status more accurately (1.4) - 7/24/20
# - Changed cert policy that gets installed, added deviceCertName variable to re-check (1.5) 9/25/20
# - Support for macOS 11 and install device certs on 11.x machines using config profile link - (1.6) 2/16/21 
# - Cleaned up script (1.7) - 6/24/22
#
####################################################################################################


##################################################################
## Script variables (edit)
##################################################################

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


function deviceCertCheck ()
{
echo "Script >>> =================================================="
echo "Script >>> CHECKING DEVICE CERTIFICATE"
echo "Script >>> =================================================="

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/Frameworks/SecurityInterface.framework/Versions/A/Resources/CertLargeStd@2x.png"

loggedInUser=$(stat -f%Su /dev/console)
userUID=$(id -u ${loggedInUser})
hostname=$(hostname)
deviceCertName=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -c "$hostname" | grep "alis" | awk '{print $1}' | tr -d '"' | cut -c 12-50)
deviceCertCount=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -a -c "$hostname" -Z | grep -c ^SHA-1)
deviceCertHash=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -a -c "$hostname" -Z | grep ^SHA-1 | cut -c 13-99)
certExpiry1=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -c "$hostname" -p | openssl x509 -text | grep "Not After" | awk '{print $4,$5,$7}' | sed "s/ /-/g; s/Jan/January/g; s/Feb/February/g; s/Mar/March/g; s/Apr/April/g; s/May/May/g; s/Jun/June/g; s/Jul/July/g; s/Aug/August/g; s/Sep/September/g; s/Oct/October/g; s/Nov/November/g; s/Dec/December/g")
# year-month-day format
certExpiry2=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -c "$hostname" -p | openssl x509 -text | grep "Not After" | awk '{print $7,$4,$5}' | sed "s/ /, /g; s/Jan/1/g; s/Feb/2/g; s/Mar/3/g; s/Apr/4/g; s/May/5/g; s/Jun/6/g; s/Jul/7/g; s/Aug/8/g; s/Sep/9/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g")
# year-month-day format
dateToday=$(date -j | awk '{print $6,$2,$3}' | sed "s/ /, /g; s/Jan/1/g; s/Feb/2/g; s/Mar/3/g; s/Apr/4/g; s/May/5/g; s/Jun/6/g; s/Jul/7/g; s/Aug/8/g; s/Sep/9/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g")
daysTillExpiry=$(python -c "from datetime import date; print date($certExpiry2).toordinal() - date($dateToday).toordinal()")


# Duplicate device certificate check
echo "Script >>> CHECK 1 - DUPLICATES"

if [ "$deviceCertName" ]; then
	
	if [ $deviceCertCount -gt "1" ]; then
		
		echo "Script >>> FAILED!"
		
		echo "Script >>> Found ($deviceCertCount) duplicate device certificates"

		echo "Script >>> Hashs: $deviceCertHash"
	
		echo "Script >>> Prompting user to fix"

		# Display jamfHelper message
		userChoice=$("$jamfHelper" -windowType "hud" -heading "ACTION NEEDED!" -description "Multiple Device Certificates Found \
		
		
Resolving this will prevent connection issues to the network (including VPN)." -button1 "Fix" -button2 "Close" -icon "$icon" -windowPosition "lr" -defaultButton 0 -lockHUD)

				# User clicked Fix
				if [ "$userChoice" == "0" ]; then

					echo "Script >>> User Clicked Fix"
			
					# Caffinate the update process
					caffeinate -d -i -m -u &
					caffeinatepid=$!

					# Display jamfHelper message
					"$jamfHelper" -windowType hud -description "Cleaning up duplicate device certificates, this may take some time..." -icon "$icon" -lockHUD > /dev/null 2>&1 &
			
					macOS=$(sw_vers -productVersion | cut -c 1-2)
					if [ "$macOS" = "10" ]; then
						# Run JAMF policy (Device Cert only) on macOS version 10
						echo "macOS 10.x found"
						jamf policy -id 1084
					else
						# Run JAMF policy (Device Cert only) on macOS version 11
						echo "macOS 11.x found"
						open "jamfselfservice:///content?entity=configprofile&id=278&action=execute"
					fi

					# Kill jamfhelper
					killall jamfHelper > /dev/null 2>&1

					# Kill the caffinate process
					kill "$caffeinatepid"

					# User clicked Close
					elif [ "$userChoice" == "2" ]; then

					echo "Script >>> User Clicked Close"

					exit 1

				fi

	else
		
		echo "Script >>> No duplicates found"
		
		echo "Script >>> PASSED!"
		
	fi
	
else

		echo "Script >>> Device Certificate Not Found"
		
		echo "Script >>> FAILED!"

		echo "Script >>> Prompting user to install"

		# Display jamfHelper message
		userChoice=$("$jamfHelper" -windowType "hud" -heading "ACTION NEEDED!" -description "Device Certificate Missing \


To connect to the network (at the office or VPN) a device certificate needs to be installed." -button1 "Install" -button2 "Close" -icon "$icon" -windowPosition "lr" -defaultButton 0 -lockHUD)

		# User clicked Install
		if [ "$userChoice" == "0" ]; then

			echo "Script >>> User Clicked Install"
			
			# Caffinate the update process
			caffeinate -d -i -m -u &
			caffeinatepid=$!

			# Display jamfHelper message
			"$jamfHelper" -windowType hud -description "Installing a device certificate, this may take some time..." -icon "$icon" -lockHUD > /dev/null 2>&1 &
			
			macOS=$(sw_vers -productVersion | cut -c 1-2)
			if [ "$macOS" = "10" ]; then
				# Run JAMF policy (Device Cert only) on macOS version 10
				echo "macOS 10.x found"
				jamf policy -id 1084
			else
				# Run JAMF policy (Device Cert only) on macOS version 11
				echo "macOS 11.x found"
				open "jamfselfservice:///content?entity=configprofile&id=278&action=execute"
			fi
			
			# Kill jamfhelper
			killall jamfHelper > /dev/null 2>&1

			# Kill the caffinate process
			kill "$caffeinatepid"

			# User clicked Close
			elif [ "$userChoice" == "2" ]; then

			echo "Script >>> User Clicked Close"

			exit 1

		fi

fi

echo "Script >>> CHECK 2 - EXPIRATION"

deviceCertName=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -c "$hostname" | grep "alis" | awk '{print $1}' | tr -d '"' | cut -c 12-50)

if [ "$deviceCertName" ]; then

	if [ "$daysTillExpiry" -lt "15" ]; then

		echo "Script >>> Status: Expiring Soon (< 14 days)"

		echo "Script >>> Prompting user to renew"

		# Display jamfHelper message
		userChoice=$("$jamfHelper" -windowType "hud" -description "Machine Certificate Expires: \


$certExpiry1 ($daysTillExpiry days left) \


Renew this certificate to continue using network connections (including VPN)." -button1 "Renew" -button2 "Close" -icon "$icon" -windowPosition "lr" -defaultButton 0 -lockHUD)

		# User clicked Renew
		if [ "$userChoice" == "0" ]; then

			echo "Script >>> User Clicked Renew"
			
			# Caffinate the update process
			caffeinate -d -i -m -u &
			caffeinatepid=$!

			# Display jamfHelper message
			"$jamfHelper" -windowType hud -description "Installing a device certificate, this may take some time..." -icon "$icon" -lockHUD > /dev/null 2>&1 &
			
			macOS=$(sw_vers -productVersion | cut -c 1-2)
			if [ "$macOS" = "10" ]; then
				# Run JAMF policy (Device Cert only) on macOS version 10
				echo "macOS 10.x found"
				jamf policy -id 1084
			else
				# Run JAMF policy (Device Cert only) on macOS version 11
				echo "macOS 11.x found"
				open "jamfselfservice:///content?entity=configprofile&id=278&action=execute"
			fi

			# Kill jamfhelper
			killall jamfHelper > /dev/null 2>&1

			# Kill the caffinate process
			kill "$caffeinatepid"

			# User clicked Close
			elif [ "$userChoice" == "2" ]; then

				echo "Script >>> User Clicked Close"

				exit 1

		fi

	else
				
		certReport

	fi

else

	echo "Script >>> Device Certificate Not Found"
		
	echo "Script >>> FAILED!"

	echo "Script >>> Prompting user to install"

	# Display jamfHelper message
	userChoice=$("$jamfHelper" -windowType "hud" -heading "ACTION NEEDED!" -description "Device Certificate Missing \


To connect to the network (at the office or VPN) a device certificate needs to be installed." -button1 "Install" -button2 "Close" -icon "$icon" -windowPosition "lr" -defaultButton 0 -lockHUD)

	# User clicked Install
	if [ "$userChoice" == "0" ]; then

		echo "Script >>> User Clicked Install"
		
		# Caffinate the update process
		caffeinate -d -i -m -u &
		caffeinatepid=$!
		
		# Display jamfHelper message
		"$jamfHelper" -windowType hud -description "Installing a device certificate, this may take some time..." -icon "$icon" -lockHUD > /dev/null 2>&1 &
			
		macOS=$(sw_vers -productVersion | cut -c 1-2)
		if [ "$macOS" = "10" ]; then
			# Run JAMF policy (Device Cert only) on macOS version 10
			echo "macOS 10.x found"
			jamf policy -id 1084
		else
			# Run JAMF policy (Device Cert only) on macOS version 11
			echo "macOS 11.x found"
			open "jamfselfservice:///content?entity=configprofile&id=278&action=execute"
		fi

		# Kill jamfhelper
		killall jamfHelper > /dev/null 2>&1

		# Kill the caffinate process
		kill "$caffeinatepid"

		# User clicked Close
		elif [ "$userChoice" == "2" ]; then

		echo "Script >>> User Clicked Close"

		exit 1

	fi

fi

echo "Script >>> =================================================="
echo "Script >>> =================================================="
}


function certReport ()
{

loggedInUser=$(stat -f%Su /dev/console)
userUID=$(id -u ${loggedInUser})
hostname=$(hostname)
deviceCertName=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -c "$hostname" | grep "alis" | awk '{print $1}' | tr -d '"' | cut -c 12-50)
deviceCertHash=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -a -c "$hostname" -Z | grep ^SHA-1 | cut -c 13-99)
certExpiry1=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -c "$hostname" -p | openssl x509 -text | grep "Not After" | awk '{print $4,$5,$7}' | sed "s/ /-/g; s/Jan/January/g; s/Feb/February/g; s/Mar/March/g; s/Apr/April/g; s/May/May/g; s/Jun/June/g; s/Jul/July/g; s/Aug/August/g; s/Sep/September/g; s/Oct/October/g; s/Nov/November/g; s/Dec/December/g")
# year-month-day format
certExpiry2=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" security find-certificate -c "$hostname" -p | openssl x509 -text | grep "Not After" | awk '{print $7,$4,$5}' | sed "s/ /, /g; s/Jan/1/g; s/Feb/2/g; s/Mar/3/g; s/Apr/4/g; s/May/5/g; s/Jun/6/g; s/Jul/7/g; s/Aug/8/g; s/Sep/9/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g")
# year-month-day format
dateToday=$(date -j | awk '{print $6,$2,$3}' | sed "s/ /, /g; s/Jan/1/g; s/Feb/2/g; s/Mar/3/g; s/Apr/4/g; s/May/5/g; s/Jun/6/g; s/Jul/7/g; s/Aug/8/g; s/Sep/9/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g")
daysTillExpiry=$(python -c "from datetime import date; print date($certExpiry2).toordinal() - date($dateToday).toordinal()")

echo "Script >>> Found a Valid Certificate"
				
echo "Script >>> Name: $deviceCertName"

echo "Script >>> Hash: $deviceCertHash"

echo "Script >>> Expires: $certExpiry1 ($daysTillExpiry days)"
				
echo "Script >>> PASSED!"

}


##################################################################
## Main script
##################################################################

networkCheck

deviceCertCheck
