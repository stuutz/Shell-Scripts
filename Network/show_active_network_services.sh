#!/bin/bash

services=$(networksetup -listnetworkserviceorder | grep 'Hardware Port')

while read line; do
	sname=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $2}')
	sdev=$(echo $line | awk -F  "(, )|(: )|[)]" '{print $4}')
	#echo "Current service: $sname, $sdev, $currentservice"
	if [ -n "$sdev" ]; then
		ifout="$(ifconfig $sdev 2>/dev/null)"
		echo "$ifout" | grep 'status: active' > /dev/null 2>&1
		rc="$?"
		if [ "$rc" -eq 0 ]; then
			currentservice="$sname"
			currentdevice="$sdev"
			currentmac=$(echo "$ifout" | awk '/ether/{print $2}')

			# may have multiple active devices, so echo it here
			echo "$currentservice, $currentdevice, $currentmac"
		fi
	fi
done <<< "$(echo "$services")"

if [ -z "$currentservice" ]; then
	>&2 echo "Could not find current service"
	exit 1
fi

exit 0