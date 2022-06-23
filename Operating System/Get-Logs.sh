#!/bin/sh

####################################################################################################
#
# CREATED BY
#
# Brian Stutzman
#
# DESCRIPTION
#
# Type: SELF SERVICE POLICY
#
# This script is meant to be ran from Self Service to gather important system and user logs to
# help in diagnosing computer issues.  The script will copy all the logs into a folder, the folder
# will be zipped to lower the file size and then saved to the Desktop so it can be easily uploaded
# to a ticket or email.
#
# VERSION
#
# - 1.5
#
# CHANGE HISTORY
#
# - Created script (1.0) - 4/28/2017
# - Removed cocoaDialog app dependency (1.1) - 4/22/2019
# - Modified the IF statement for the icon variable to support 10.15 (1.2) - 9/9/2019
# - Added icon path for macOS 11.0 in the JAMF Helper window (1.3) - 10/13/2020
# - Added icon path for macOS 12.0 in the JAMF Helper window (1.4) - 12/8/2021
# - Fixed the logged in user variable by removing python command (1.5) - 1/11/2022
#
####################################################################################################


##################################################################
## Script variables
##################################################################
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
userNAME=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
computerNAME=$(scutil --get ComputerName)
dateFORMAT=$(date +"%m-%d-%Y_%H.%M.%S")
osVersion=$(sw_vers -productVersion | cut -c 1-5)
osVersionShort=$(sw_vers -productVersion | cut -c 1-2)

# Get window icon based on macOS version
if [ "$osVersion" = "10.13" ] || [ "$osVersion" = "10.14" ]; then
icon="/Applications/Utilities/Console.app/Contents/Resources/AppIcon.icns"
fi

if [ "$osVersion" = "10.15" ] || [ $osVersionShort = "11" ] || [ $osVersionShort = "12" ]; then
icon="/System/Applications/Utilities/Console.app/Contents/Resources/AppIcon.icns"
fi


##################################################################
## First dialog message to user, gathering logs
##################################################################
function FirstNotify ()
{
  # Caffinate the process
  caffeinate -d -i -m -u &
  caffeinatepid=$!

  "$jamfHelper" -windowType hud -description "Gathering log files, this may take some time..." -icon "$icon" -lockHUD > /dev/null 2>&1 &

  # Gather all the important system & user log files
  mkdir /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT}
  cp -r /Users/${userNAME}/Library/Logs /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT}/${userNAME}_Library_Logs
  cp -r /Library/Logs /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT}/Library_Logs
  cp -r /private/var/log /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT}/var_logs

  # Change permissions on the log files
  chmod -R 777 /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT}

  sleep 3

  # Convert log folder to zip format
  ditto -c -k --sequesterRsrc --keepParent /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT} /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT}.zip

  sleep 2

  # Delete log folder
  rm -R /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT}

  sleep 2

  # Move zip file to users desktop
  mv /Users/Shared/${computerNAME}_${userNAME}_${dateFORMAT}.zip /Users/$userNAME/Desktop

  sleep 2

  # Kill jamfhelper
  killall jamfHelper > /dev/null 2>&1

  # Kill the caffinate process
  kill "$caffeinatepid"
}


##################################################################
## Final dialog message to user, logs successfully gathered
##################################################################
function FinalNotify ()
{
    "$jamfHelper" -windowType hud -description "The logs are saved to your desktop as: \

     ${computerNAME}_${userNAME}_${dateFORMAT}.zip \


Email zip file to support or attach to a ticket." \
    -icon "$icon" -button1 CLOSE -defaultButton 0 -lockHUD > /dev/null 2>&1
}


##################################################################
## Main script
##################################################################
FirstNotify

FinalNotify


exit 0
