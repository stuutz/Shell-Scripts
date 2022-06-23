#!/bin/sh

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
# 	Type: SELF SERVICE
#
#	This script will remove the profile with the AD payload that generates the machine certificate.
#	After the certificate is remove it will reinstall the profile to create a new machine certificate.
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 6/21/19 (1.0)
#
####################################################################################################


##################################################################
## Script variables
##################################################################

hostname=$(hostname)
certExpiry1=$(security find-certificate -c "$hostname" -p | openssl x509 -text | grep "Not After" | awk '{print $4,$5,$7,$6,$8}' | sed "s/ /-/g; s/Jan/January/g; s/Feb/February/g; s/Mar/March/g; s/Apr/April/g; s/Jun/June/g; s/Jul/July/g; s/Aug/August/g; s/Sep/September/g; s/Oct/October/g; s/Nov/November/g; s/Dec/December/g")
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
iconError="/System/Library/CoreServices/ReportPanic.app/Contents/Resources/ProblemReporter.icns"
iconSuccess="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Clock.icns"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
ethernetProID="ETHERNET PROFILE ID"
networkProCheck=$(profiles show | grep "attribute: name: Network" | awk '{print $4}')


##################################################################
## Main script
##################################################################

# Display jamfHelper message
userChoice=$("$jamfHelper" -windowType "hud" -title "Certificate Expiration Checker" -description "Machine Certificate Expires: \


$certExpiry1" -button1 "Close" -button2 "Renew" -icon "$icon" -lockHUD )

		# If statement to determine if the old Network profile is installed
    	if [ "$userChoice" == "2" ]; then
            
			echo ">> User Clicked Renew"
            
            if [ "$networkProCheck" = "Network" ]; then
            
            	# Display jamfHelper message        
        		"$jamfHelper" -windowType "hud" -title "Certificate Expiration Checker" -heading "Error!" -description "This workflow is incompatible with this computer due to having an older Network profile installed." -button1 "Close" -icon "$iconError" -lockHUD

				exit 0
                
			else
                
				# Display jamfHelper message        
        		"$jamfHelper" -windowType "hud" -title "Certificate Expiration Checker" -description "Before clicking "Continue" unplugged the Ethernet cable from the computer and connect to "BE-FREE" wireless network." -button1 "Continue" -icon "$icon" -lockHUD
            
            	# Policy to remove Ethernet & AD profile and reinstall
            	jamf policy -id $4
                
                certExpiry2=$(security find-certificate -c "$hostname" -p | openssl x509 -text | grep "Not After" | awk '{print $4,$5,$7,$6,$8}' | sed "s/ /-/g; s/Jan/January/g; s/Feb/February/g; s/Mar/March/g; s/Apr/April/g; s/Jun/June/g; s/Jul/July/g; s/Aug/August/g; s/Sep/September/g; s/Oct/October/g; s/Nov/November/g; s/Dec/December/g")

        		# Display jamfHelper message        
        		"$jamfHelper" -windowType "hud" -title "Certificate Expiration Checker" -heading "Certificate Renewed!" -description "Expiration will now be on: \
			
            
$certExpiry2" -button1 "Close" -icon "$iconSuccess" -lockHUD

				exit 0

			fi
            
		else

        	echo ">> User Clicked Close"
        
        	exit 0
        
		fi
        
exit 0