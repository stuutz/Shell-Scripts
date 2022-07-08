#!/bin/sh

userAct="$4"
userPWD="$5"
admUser="$6"
admPWD="$7"

sysadminctl -resetPasswordFor "$userAct" -newPassword "$userPWD" -adminUser "$admUser" -adminPassword "$admPWD"

exit 0