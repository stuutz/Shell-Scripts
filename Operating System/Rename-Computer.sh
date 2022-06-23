#!/bin/bash

####################################################################################################
#
# DESCRIPTION
#
#	This script will rename the computer and hostname with the hardware serial number.  It will also
#	append text before the serial number.
#
####################################################################################################


# rename the hostname with the computers serial number.
a=$(system_profiler SPHardwareDataType | grep Serial | cut -d ":" -f2 | cut -d " " -f2)
SN2=MAC$a
scutil --set ComputerName $SN2
scutil --set LocalHostName $SN2
scutil --set HostName $SN2
defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName "$SN2"

exit 0
