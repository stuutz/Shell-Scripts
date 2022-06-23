#!/bin/bash

# change daysPWValid below to a days value that your passwords need to change. For example, if they expire after 60 days, put in 60. If 90 days, put in 90, etc.
daysPWValid="90"
secsPWValid=$((60*60*24*daysPWValid))
timeNow=$(date +"%s")

# change "ORG" in the below to the correct domain name
domain=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')

if [ "$domain" = "DOMAIN NAME" ]; then
  domainPath="/Active Directory/DOMAIN NAME/All Domains"
  echo "$domainPath"
fi

# this gets the current logged in user. Use a different method of getting the user if needed, or hard code a name in.
currentUser=$(stat -f%Su /dev/console)

# gets the raw last password set value from AD
lastPWChangeRaw=$(dscl "$domainPath" read /Users/${currentUser} SMBPasswordLastSet | cut -d' ' -f2)

# does calculation to get some values we need on the next password change + how many days left
if [ "$lastPWChangeRaw" != "" ]; then
    lastPWChangeTrue=$((lastPWChangeRaw/10000000-11644473600))
    nextPWChangePlusTime=$((lastPWChangeTrue+secsPWValid))
    nextPWChange=$(date -jf "%s" "$nextPWChangePlusTime" +"%m-%d-%Y %r")
    daysToChange=$((((nextPWChangePlusTime-timeNow))/60/60/24))
    echo "$daysToChange"
else
    echo "No Last Password Set date was found."
    exit 0
fi
