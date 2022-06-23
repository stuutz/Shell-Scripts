#!/bin/sh


osascript -e '

tell application "Finder" to open file "Accounts.prefpane" of (path to system preferences)

tell application "System Events"
	tell application process "System Preferences"
		delay 1
		click button "Change Password…" of tab group 1 of window "Users & Groups"
	end tell
end tell
'

exit 0
