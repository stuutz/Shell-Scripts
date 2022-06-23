#!/bin/bash

# sets the computers MODEL IDENTIFER
MID=$(sysctl hw.model | awk -F. '{print $2}' | cut -c 8-21)

# disable the username and password login 'option + return' at screensaver or locked screen
if [[ "$MID" = "MacBookPro13,3" || "$MID" = "MacBookPro13,2" ]]; then
	echo "- Touch ID $MID verified.  Not applying admin bypass screensaver setting."
else
	echo "- Non-Touch ID computer.  Disabling the ability for admin to bypass lock screen."
	# disables the ability for admin to bypass lock screen
	security authorizationdb write system.login.screensaver authenticate-session-user
fi

exit 0
