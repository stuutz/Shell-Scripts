#!/bin/bash
####################################################################################################
#
# Installs Root and Subordinate PKIs
#
####################################################################################################

# trust the certificates and install into the keychain
security add-trusted-cert -d -k /Library/Keychains/System.keychain /Users/Shared/ROOT.cer
security add-trusted-cert -d -r trustAsRoot -k /Library/Keychains/System.keychain /Users/Shared/Subordinate.cer

sleep 3

# remove imported certificates
rm /Users/Shared/ROOT.cer
rm /Users/Shared/Subordinate.cer

exit 0