#!/bin/bash

# setup AD admin groups
dsconfigad -group "COMPANY\Domain Admins,CompanyName\Domain Admins"
dsconfigad -group "COMPANY\Domain Admins,CompanyName\Local Desktop Admins"

exit 0