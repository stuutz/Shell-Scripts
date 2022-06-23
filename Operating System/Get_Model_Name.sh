#!/bin/bash


# get model name
modelName=$(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3}')

echo "$modelName"

exit 0
