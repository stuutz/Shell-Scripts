#!/bin/bash


# determines if the computer has Touch ID (1 - yes) (0 - no)
TouchIDStatus=$(bioutil -rs | grep functionality | awk '{print $4}')

# if statement to determine if machine has Touch ID
if [[ "$TouchIDStatus" = "0" ]]; then
	echo "Non-Touch ID Machine"
elif [[ "$TouchIDStatus" = "1" ]]; then
	echo "Touch ID Machine Verified."
else
	echo "Error identifying Touch ID status..."
fi


exit 0
