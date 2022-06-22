#!/bin/bash

# Loop to verify AD connection
domainStatus=$(odutil show nodenames | grep "/Active Directory/DOMAIN NAME" | grep "DOMAIN.corp" | grep "Online" | awk '{print $3}')

until [ "$domainStatus" = "Online" ]
do
	echo "AD Not Bound..."
	sleep 3
	domainStatus=$(odutil show nodenames | grep "/Active Directory/DOMAIN NAME" | grep "DOMAIN.corp" | grep "Online" | awk '{print $3}')
done

echo "<< AD Bound >>"