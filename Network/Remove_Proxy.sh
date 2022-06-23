#!/bin/sh


# Detects all network hardware & creates services for all installed network hardware
/usr/sbin/networksetup -detectnewhardware

IFS=$'\n'

#Loops through the list of network services
for i in $(/usr/sbin/networksetup -listallnetworkservices | tail +2 );

        do

                # In absence of being able to unset the auto proxy, set it to " "
                /usr/sbin/networksetup -setautoproxyurl "$i" " "
                echo "Removed proxy for $i"

                # Turn off auto proxy
                /usr/sbin/networksetup -setautoproxystate "$i" off
                echo "Turned off auto proxy for interface $i"

		            # Clear out bypass proxy settings box
                /usr/sbin/networksetup -setproxybypassdomains "$i" " "
                echo "Cleared bypass proxy settings box for $i"

        done

unset IFS

echo "Auto proxy for all interfaces turned off"