#!/bin/sh
# template script for running a command as user
# The presumption is that this script will be executed as root from a launch daemon
# or from some management agent. To execute a single command as the current user
# you can use the `runAsUser` function below.
# by Armin Briegel - Scripting OS X
# 
# sample code for this blog post
# https://scriptingosx.com/2020/08/running-a-command-as-another-user/
# Permission is granted to use this code in any way you want.
# Credit would be nice, but not obligatory.
# Provided "as is", without warranty of any kind, express or implied.
# variable and function declarations
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
# get the currently logged in user
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
# global check if there is a user logged in
if [ -z "$currentUser" -o "$currentUser" = "loginwindow" ]; then
echo "no user logged in, cannot proceed"
exit 1
fi
# now we know a user is logged in
# get the current user's UID
uid=$(id -u "$currentUser")
# convenience function to run a command as the current user
# usage:
#   runAsUser command arguments...
runAsUser() {  
if [ "$currentUser" != "loginwindow" ]; then
	launchctl asuser "$uid" sudo -u "$currentUser" "$@"
else
echo "no user logged in"
# uncomment the exit command
# to make the function exit with an error when no user is logged in
# exit 1
fi
}
# main code starts here
# open a website in the current user's default browser
runAsUser open "https://scriptingosx.com"
# other examples
# set a preference
#
# runAsUser defaults write com.apple.dock orientation left
# run an AppleScript command
#
# runAsUser osascript -e 'display dialog "Hello, World!"'
# load a launch agent
#
# runAsUser launchctl load com.example.agent
