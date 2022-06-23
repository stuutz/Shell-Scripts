#!/bin/bash
####################################################################################################
#
# ABOUT THIS SCRIPT
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#   This script is ran at startup on every newly imaged computer.  It configures various settings
#   for macOS.
#
####################################################################################################


## (1) Add directory domains for search policy AD authentication
dscl /Search -append / CSPSearchPath "/Active Directory/DOMAIN NAME HERE"

## (2) Add directory domains for search policy AD contacts
dscl /Search/Contacts -append / CSPSearchPath "/Active Directory/DOMAIN NAME HERE"

## (3) Configure system account password expiry
dsconfigad -passinterval 90

## (4) Set the notification time when AD password is about to expire at login window
defaults write /Library/Preferences/com.apple.loginwindow PasswordExpirationDays 14

## (5) Enable admin account for Apple Remote Desktop access
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users admin -access -on -restart -privs -DeleteFiles -TextMessages -OpenQuitApps -GenerateReports -RestartShutDown -SendFiles -ChangeSettings -controlobserve -activate

## (6) Unlock system preferences panes for standard user editing
security authorizationdb write system.preferences allow
security authorizationdb write system.services.systemconfiguration.network allow
security authorizationdb write system.preferences.timemachine allow
security authorizationdb write system.preferences.network allow
security authorizationdb write system.preferences.energysaver allow
security authorizationdb write system.preferences.printing allow
security authorizationdb write system.preferences.datetime allow

## (7) Enable SSH
systemsetup -setremotelogin on

## (8) Set network time server
systemsetup -setnetworktimeserver "TIME SERVER HERE"
systemsetup -setusingnetworktime on

## (9) Set time zone
systemsetup -settimezone "America/New_York"

## (10) Enable time zone shift based on device location
defaults write /Library/Preferences/com.apple.timezone.auto.plist Active 1

## (11) Disable Apple software updates
softwareupdate --schedule off

## (12) Add users to CUPS permissions group so everyone can pause/resume printing services
dseditgroup -o edit -a everyone -t group _lpadmin

## (13) Disable Time Machines & pop-up message whenever an external drive is plugged in
defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

## (14) Disable Image Capture from loading when a device is plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

## (15) Disable apps from installing when downloaded from other machines via iCloud account
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 0

## (16) Enable machine certificate auto renewal
defaults write /Library/Preferences/com.apple.mdmclient AutoRenewCertificatesEnabled -bool YES

## (17) Configures search domains for all network services
networksetup -setsearchdomains Belkin\ USB-C\ LAN "DOMAIN NAME HERE" "DOMAIN NAME HERE"
networksetup -setsearchdomains Thunderbolt\ Ethernet "DOMAIN NAME HERE" "DOMAIN NAME HERE"
networksetup -setsearchdomains Wi-Fi "DOMAIN NAME HERE" "DOMAIN NAME HERE"
networksetup -setsearchdomains Ethernet "DOMAIN NAME HERE" "DOMAIN NAME HERE"
networksetup -setsearchdomains Ethernet\ 1 "DOMAIN NAME HERE" "DOMAIN NAME HERE"
networksetup -setsearchdomains Ethernet\ 2 "DOMAIN NAME HERE" "DOMAIN NAME HERE"
networksetup -setsearchdomains Apple\ USB\ Ethernet\ Adapter "DOMAIN NAME HERE" "DOMAIN NAME HERE"
networksetup -setsearchdomains Display\ Ethernet "DOMAIN NAME HERE" "DOMAIN NAME HERE"
networksetup -setsearchdomains USB\ 10/100/1000\ LAN "DOMAIN NAME HERE" "DOMAIN NAME HERE"


exit 0
