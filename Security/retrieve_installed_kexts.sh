#!/bin/sh

# Gather list of User Approved Kernel Extensions.

user=`ls -l /dev/console | awk '{print $3}'`
folder=/Users/$user/Desktop/KEXTsResults
file=checkKEXTs.csv

# Create folder
/bin/mkdir -p ${folder}
/usr/sbin/chown root:admin ${folder}
/bin/chmod 755 ${folder}

/usr/bin/sqlite3 -csv /var/db/SystemPolicyConfiguration/KextPolicy "select team_id,bundle_id from kext_policy" > ${folder}/${file}

exit 0
