#!/bin/bash


# set network location for offsite
offLocation="Home";

# setup a location for offsite (ex: home, coffee shop)
networksetup -createlocation "$offLocation" populate

# configures search domains and DNS servers for Automatic network location
networksetup -listallnetworkservices | grep -i -E 'Ethernet|Wi-Fi|Belkin USB-C LAN|USB 10/100/1000 LAN' | while read service
do
  networksetup -setsearchdomains "$service" DOMAIN DOMAIN DOMAIN
  networksetup -setdnsservers "$service" SERVER_IP SERVER_IP SERVER_IP
done

exit 0
