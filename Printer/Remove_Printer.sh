#!/bin/bash

## Remove all installed printers
lpstat -p | awk '{print $2}' | while read printer
do
	echo "Deleting Printer:" $printer
	lpadmin -x $printer
done

## Remove individual printer by name
#lpadmin -x "HP-602-PCL6"
#lpadmin -x "HP-4250-PCL6-Marketing"


exit 0