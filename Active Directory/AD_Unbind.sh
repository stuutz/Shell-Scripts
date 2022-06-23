#!/bin/bash

# force unbind from AD
dsconfigad -force -remove -u johndoe -p nopasswordhere

exit 0
