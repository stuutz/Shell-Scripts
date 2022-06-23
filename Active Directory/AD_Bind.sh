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
# 	This script will check the domain bound status and bound if not bound.
#
# VERSION
# 
# 	1.1
#
####################################################################################################
# CHANGE HISTORY
#
# - Created script (1.0) - 2/9/2022
# - Added icons to the JAMF window to show domain bind status (1.1) - 3/2/2022
#
####################################################################################################


##################################################################
## Script functions
##################################################################

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
#icon="/System/Library/PreferencePanes/SoftwareUpdate.prefPane/Contents/Resources/SoftwareUpdate.icns"
onlineIcon="/private/var/tmp/greenDot.icns"
offlineIcon="/private/var/tmp/redDot.icns"

##################################################################
## Script functions
##################################################################

function networkCheck ()
{
domainStatus=$(odutil show nodenames | grep "/Active Directory/COMPANY/DOMAIN" | sed -n 1p | awk '{print $3}')

if [[ $domainStatus = "Online" ]]; then

	echo "Script result: Domain connected and online"
    
	"$jamfHelper" -windowType "hud" -icon "$onlineIcon" -description "Domain connected and online." -button1 "CLOSE" -defaultButton 0 -lockHUD
	
else

	if [[ $domainStatus = "Offline" ]]; then
	
		echo "Script result: Domain disconnected and offline"
        
		userChoice=$("$jamfHelper" -windowType "hud" -icon "$offlineIcon" -description "Computer is not bound.
    
Do you want to bind?" -button1 "CLOSE" -button2 "YES" -defaultButton 0 -lockHUD)

		# YES button was pressed
		if [ "$userChoice" == "2" ]; then
        
        	bindPolicy

        	recheck
            
			# CANCEL button was pressed
			elif [ "$userChoice" == "0" ]; then
		
				echo "Script result: User canceled"
                
                cleanUp
		
				exit 0
		
			fi
            
		elif [[ $domainStatus = "" ]]; then
	
			echo "Script result: Domain not found"
            
			userChoice=$("$jamfHelper" -windowType "hud" -icon "$offlineIcon" -description "Computer is not bound.
    
Do you want to bind?" -button1 "CLOSE" -button2 "YES" -defaultButton 0 -lockHUD)

			# YES button was pressed
			if [ "$userChoice" == "2" ]; then
        
        		bindPolicy

        		recheck
            
				# CANCEL button was pressed
				elif [ "$userChoice" == "0" ]; then
		
					echo "Script result: User canceled"
                    
                    cleanUp
		
					exit 0
		
				fi

		else
	
		echo "Script result: Domain not connected"
        
		userChoice=$("$jamfHelper" -windowType "hud" -icon "$offlineIcon" -description "Computer is not bound.
    
Do you want to bind?" -button1 "CLOSE" -button2 "YES" -defaultButton 0 -lockHUD)

		# YES button was pressed
		if [ "$userChoice" == "2" ]; then
        
        	bindPolicy

        	recheck
            
			# CANCEL button was pressed
			elif [ "$userChoice" == "0" ]; then
		
				echo "Script result: User canceled"
                
                cleanUp
		
				exit 0
		
			fi
        
	fi

fi
}


function bindPolicy ()
{
	jamf policy -id 404
}


function recheck ()
{
    domainStatus2=$(odutil show nodenames | grep "/Active Directory/COMPANY/DOMAIN" | sed -n 1p | awk '{print $3}')
	
    if [[ $domainStatus2 = "Online" ]]; then

		echo "Script result: recheck passed, bind successful"
    
		"$jamfHelper" -windowType "hud" -icon "$onlineIcon" -description "Domain connected and online." -button1 "CLOSE" -defaultButton 0 -lockHUD

	else
	
		echo "Script result: recheck failed"
        
		"$jamfHelper" -windowType "hud" -icon "$offlineIcon" -description "Computer failed to bind, try again." -button1 "CLOSE" -defaultButton 0 -lockHUD

	fi
}


function cleanUp ()
{
	rm -rf $onlineIcon
	rm -rf $offlineIcon
}

##################################################################
## Main script
##################################################################

echo ""

networkCheck

cleanUp