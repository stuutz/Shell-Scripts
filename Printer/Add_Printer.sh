#!/bin/sh

####################################################################################################
# ABOUT THIS SCRIPT
#
# CREATED BY
#   Brian Stutzman
#
# DESCRIPTION
#   This script is used to install network attached printers.  The printer drivers need to be
#	pre-installed.
#
####################################################################################################
# CHANGE HISTORY
#
# - Created script - 8/29/19
#
####################################################################################################


##################################################################
## Script variables (EDIT)
##################################################################

# Printer name as seen by the cups process. Use a name with no spaces, or substitute underscores for the space
PrinterName="1491-3-Xerox-C60-BWY21"

# Printer name that is visible in the GUI.  Can be different than cups name but its good to keep the same
GUIName="First Floor - Marketing - Xerox"

# IP or DNS of printer
ip="IP ADDRESS"

# Options: Hold, Print
queue="Print"

# Printer location description
location="First Floor - (1491)"

# Print driver install location
driver="/Library/Printers/PPDs/Contents/Resources/en.lproj/Xerox EX C60-C70 Printer"


##################################################################
## Main script (DON'T EDIT)
##################################################################

# Install printer
/usr/sbin/lpadmin -p "$PrinterName" -E -o printer-is-shared=false -v lpd://${ip}/${queue} \
-D "$GUIName" -L "$location" -P "$driver"


# Set additional printer options/features
#/usr/sbin/lpadmin -p "$PrinterName" -o Duplex=DuplexNoTumble -o XROutputColor=PrintAsGrayscale


exit 0
