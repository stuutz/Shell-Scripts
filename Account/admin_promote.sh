#!/bin/sh

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	Promotes logged in user to the administrator group.
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 8/7/20 (1.0)
#
####################################################################################################


##################################################################
# Script variables (DO NOT EDIT)
##################################################################

userMacOS=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')

##################################################################
# Script functions (DO NOT EDIT)
##################################################################

function promoteUser () 
{
	/usr/sbin/dseditgroup -o edit -a $userMacOS -t user admin
}


##################################################################
# main script
##################################################################

promoteUser

