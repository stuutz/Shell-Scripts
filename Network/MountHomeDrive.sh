#!/bin/sh

# Store the logged in user
user=`ls -la /dev/console | cut -d " " -f 4`

# Store the File Server
server='fileServerName.company.org'

# Path to shares
sharePath='path/to/share/container'

# Mount the user's home directory
sudo -u $user mkdir '/Volumes/Home'
sudo -u $user mount -t smbfs //$server'/'$sharePath'/'$user '/Volumes/Home'



exit 0
