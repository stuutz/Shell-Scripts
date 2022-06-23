#!/bin/bash

## Removes old local WiFi config profiles

# wireless profile name
/usr/bin/profiles -R -p com.apple.mdm.macosxod01.build1.org.e8fe2260-30a4-012f-c940-0017f293cc5c.alacarte

sleep 1

# removes the WiFi network entry from keychain
security delete-generic-password -l NetworkName

sleep 1

# turn WiFi off/on
networksetup -setairportpower en0 off
networksetup -setairportpower en1 off

sleep 2

networksetup -setairportpower en0 on
networksetup -setairportpower en1 on

sleep 2

# set auto proxy discovery settings
networksetup -setproxyautodiscovery "Wi-Fi" on
networksetup -setproxyautodiscovery "Ethernet" on
networksetup -setproxyautodiscovery "Thunderbolt Ethernet" on
networksetup -setproxyautodiscovery "Display Ethernet" on
networksetup -setproxyautodiscovery "Belkin USB-C LAN" on
networksetup -setproxyautodiscovery "USB\ 10/100/1000\ LAN" on
networksetup -setproxyautodiscovery "Ethernet\ 1" on
networksetup -setproxyautodiscovery "Ethernet\ 2" on
networksetup -setproxyautodiscovery "Apple\ USB\ Ethernet\ Adapter" on

exit 0