#!/bin/sh

#
# Using system_profiler to check the chip type (T1 or T2)
#

CHIP_TYPE=$( system_profiler SPiBridgeDataType | grep -w "chip" | awk '{print$4}' )

if [[ "${CHIP_TYPE}" = "T2" ]]; then

  echo "<result>T2</result>"

elif [[ "${CHIP_TYPE}" = "T1" ]]; then

  echo "<result>T1</result>"

elif [[ "${CHIP_TYPE}" = "" ]]; then

  echo "<result>N/A</result>"

fi



exit 0
