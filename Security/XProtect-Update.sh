#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
# 	Script will download & install XProtect definitions.
#
####################################################################################################


# enabled Apple Software Updates
softwareupdate --schedule on

# disables "automatically check for updates"
/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -boolean FALSE

sleep 2

# enables only "install system data files and security updates"
/usr/sbin/softwareupdate --background-critical

sleep 2

# disables Apple Software Updates
softwareupdate --schedule off

exit 0

