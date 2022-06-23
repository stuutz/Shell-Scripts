#!/bin/bash


## macOS version check
osCHECK=$(sw_vers -productVersion | cut -c 1-5)


## Script compatiblity check - if needed
if [[ "$osCHECK" = "10.13" || "$osCHECK" = "10.12" || "$osCHECK" = "10.11" || "$osCHECK" = "10.10" ]]; then
  echo "OS meets requirements above."
else
  echo "The installed OS is not compatible with this script...exiting"
fi


exit 0
