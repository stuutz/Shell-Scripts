#!/bin/bash

## Set Auto Proxy Discovery settings
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