#!/bin/bash

# Reference site:
# https://osxbytes.wordpress.com/2019/09/24/about-macos-catalina-bootstrap-token
# https://www.jamf.com/jamf-nation/articles/764/manually-leveraging-apple-s-bootstrap-token-functionality

version=$(sw_vers -productVersion | awk -F. '{print $1}')

if [ $version = 10 ]; then

	# The admin account needs to authenticate to validate its password to enable SecureToken on the account
	# Using dscl and -authonly is the least intrusive way to do that.
	/usr/bin/dscl /Local/Default -authonly "$4" "$5"

	# Kick off the bootstrap token escrow install. The UX is interactive.
	# Use expect to supply username and password when prompted.
	/usr/bin/expect << BOOTSTRAP

	spawn profiles install -type bootstraptoken
	sleep 1
	expect "Enter the admin user name:"
	sleep 1
	send "$4\n"
	sleep 1
	expect "Enter the password for user"
	sleep 1
	send "$5\n"
	sleep 1
	expect "profiles"
	sleep 1
	interact
	BOOTSTRAP

else 

	echo "macOS 11.0 or later installed, script not compatible."
    
    exit 0

fi