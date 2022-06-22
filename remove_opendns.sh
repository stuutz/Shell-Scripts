#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#	This script will remove OpenDNS and associating files from the machine.
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 6/3/20 (1.0)
#
####################################################################################################

user=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
fullname=`finger | grep "$user" | sed -n 1p | awk '{print $2,$3}'`
computer=$(scutil --get ComputerName)
date=$(date +"%m-%d-%Y %H:%M:%S")

echo ""
echo "************************************************"
echo "User: $fullname ($user)"
echo "Computer: $computer"
echo "Date: $date"
echo "************************************************"

# Uninstall OpenDNS
/Applications/OpenDNS\ Roaming\ Client/rcuninstall

sleep 60

# Unload Client
launchctl unload /Library/LaunchDaemons/com.opendns.osx.RoamingClientConfigUpdater.plist
launchctl unload /Library/LaunchAgents/com.cisco.umbrella.menu.plist

sleep 2

# Remove supporting files
rm -rf /Applications/OpenDNS\ Roaming\ Client/Umbrella\ Diagnostic.app
rm -rf /private/var/folders/z3/cr0dsddn3895jdy6__wdm0xh0000gn/C/com.opendns.OpenDNS-Diagnostic
rm -rf /Applications/OpenDNS\ Roaming\ Client/Umbrella\ Roaming\ Client\ Uninstaller.app
rm -rf /Applications/OpenDNS\ Roaming\ Client/UmbrellaMenu.app
rm -rf /private/var/folders/z3/cr0dsddn3895jdy6__wdm0xh0000gn/C/com.cisco.umbrella.menu.UmbrellaMenu
rm -R /Applications/OpenDNS\ Roaming\ Client
rm -R /Library/Application\ Support/OpenDNS\ Roaming\ Client

exit 0

