#!/bin/bash

####################################################################################################
#
# DESCRIPTION
#
#	This will create a script and a launch agent that will run every 4 hours to check for new
#	XProtext definitions.
#
#	Helpful sites:
#	https://macops.ca/os-x-admins-your-clients-are-not-getting-background-security-updates
#	https://derflounder.wordpress.com/2016/03/28/checking-xprotect-and-gatekeeper-update-status-on-macs/
#
####################################################################################################


SCRIPT="/Library/Scripts/XProtectUpdate.sh"
LABEL="com.org.XProtectUpdater"
AGENT=/Library/LaunchAgents/com.org.XProtectUpdater.plist
RUNNING=0
NEW=0

WriteScript() {
	/bin/echo "#!/bin/bash" > "$SCRIPT"
	/bin/echo 'softwareupdate --schedule on' >> "$SCRIPT"
	/bin/echo '/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -boolean FALSE' >> "$SCRIPT"
	/bin/echo 'sleep 2' >> "$SCRIPT"
	/bin/echo '/usr/sbin/softwareupdate --background-critical' >> "$SCRIPT"
	/bin/echo 'sleep 2' >> "$SCRIPT"
	/bin/echo 'softwareupdate --schedule off' >> "$SCRIPT"
	/bin/chmod +x "$SCRIPT"
}

WriteAgent() {
	/usr/bin/defaults write $AGENT Label -string $LABEL
	/usr/bin/defaults write $AGENT ProcessType Background
	/usr/bin/defaults write $AGENT RunAtLoad -bool true
	# Run every 4 hours (calculation - 60m x 4h = 240m x 60s = 14400s)
	/usr/bin/defaults write $AGENT StartInterval -int 14400
	/usr/bin/defaults write $AGENT ProgramArguments -array
	/usr/libexec/PlistBuddy -c "Add :ProgramArguments: string /bin/sh" $AGENT
	/usr/libexec/PlistBuddy -c "Add :ProgramArguments: string $SCRIPT" $AGENT
	/bin/chmod 644 $AGENT
}

CheckAgent() {
	if [ -f $AGENT ]; then
		RUNNING=$(/bin/launchctl list | /usr/bin/grep $LABEL | /usr/bin/wc -l)
	else
		NEW=1
	fi
}

LoadAgent() {
	/bin/launchctl load -w $AGENT
	RUNNING=1
}

Main() {
	CheckAgent
	# 1 for new agent, 0 for old
	if [ $NEW -eq 1 ]; then
		WriteAgent
		WriteScript
	fi
	# 1 for already running, 0 for not running
	if [ $RUNNING -eq 0 ]; then
		LoadAgent
	fi  
}

Main "$@"