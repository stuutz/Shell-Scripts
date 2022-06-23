#!/bin/bash

####################################################################################################
#
# DESCRIPTION
#
#	This will remove existing WiFi networks from the preferred list on different interfaces.
#
####################################################################################################


networksetup -removepreferredwirelessnetwork en0 "NetworkName1"
networksetup -removepreferredwirelessnetwork en1 "NetworkName2"

exit 0
