#!/bin/bash

# Helpful sites:
# https://macops.ca/os-x-admins-your-clients-are-not-getting-background-security-updates
# https://derflounder.wordpress.com/2016/03/28/checking-xprotect-and-gatekeeper-update-status-on-macs/


SCRIPT="/Library/Scripts/XProtectUpdate.sh"
LABEL="com.org.XProtectUpdater"
DAEMON=/Library/LaunchDaemons/com.org.XProtectUpdater.plist
# Gets the OS version
OSVERS=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')
# Regex for 10.9+
OSREGEX="^[19]?[0-9]$"
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

WriteDaemon() {
    /usr/bin/defaults write $DAEMON Label -string $LABEL
    /usr/bin/defaults write $DAEMON ProcessType Background
    /usr/bin/defaults write $DAEMON RunAtLoad -bool true
    # Run every 4 hours (calculation - 60m x 4h = 240m x 60s = 14400s)
    /usr/bin/defaults write $DAEMON StartInterval -int 14400
    /usr/bin/defaults write $DAEMON ProgramArguments -array
    /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string /bin/sh" $DAEMON
    /usr/libexec/PlistBuddy -c "Add :ProgramArguments: string $SCRIPT" $DAEMON
    /bin/chmod 644 $DAEMON
}

CheckDaemon() {
    if [ -f $DAEMON ]; then
        RUNNING=$(/bin/launchctl list | /usr/bin/grep $LABEL | /usr/bin/wc -l)
    else
        NEW=1
    fi
}

LoadDaemon() {
    /bin/launchctl load -w $DAEMON
    RUNNING=1
}

CheckOSRequirements() {
    if [[ ! $OSVERS =~ $OSREGEX ]]; then
        /bin/echo "OS Requirements not met"
        exit 0
    fi
}

Main() {
    CheckOSRequirements
    CheckDaemon
    # 1 for new daemon, 0 for old
    if [ $NEW -eq 1 ]; then
        WriteDaemon
        WriteScript
    fi
    # 1 for already running, 0 for not running
    if [ $RUNNING -eq 0 ]; then
        LoadDaemon
    fi  
}

Main "$@"