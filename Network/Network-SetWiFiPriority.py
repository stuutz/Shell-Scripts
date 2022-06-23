#!/usr/bin/python

# As written, this requires the following:
# - OS X 10.6+ (has been reported working through 10.12.3)
# - python 2.6 or 2.7 (for collections.namedtuple usage, should be fine as default python in 10.6 is 2.6)
# - pyObjC (as such, recommended to be used with native OS X python install)

# Run with root

import objc, ctypes.util, os.path, collections
from Foundation import NSOrderedSet

# List of preferred SSIDs in priority order - edit/add/delete as needed
PreferredSSIDs = ["APPLEWiFi", "MYBADWiFi"]

def load_objc_framework(framework_name):
    # Utility function that loads a Framework bundle and creates a namedtuple where the attributes are the loaded classes from the Framework bundle
    loaded_classes = dict()
    framework_bundle = objc.loadBundle(framework_name, bundle_path=os.path.dirname(ctypes.util.find_library(framework_name)), module_globals=loaded_classes)
    return collections.namedtuple('AttributedFramework', loaded_classes.keys())(**loaded_classes)

# Load the CoreWLAN.framework (10.6+)
CoreWLAN = load_objc_framework('CoreWLAN')

# Load all available wifi interfaces
interfaces = dict()
for i in CoreWLAN.CWInterface.interfaceNames():
    interfaces[i] = CoreWLAN.CWInterface.interfaceWithName_(i)

# Repeat the configuration with every wifi interface
for i in interfaces.keys():
    # Grab a mutable copy of this interface's configuration
    configuration_copy = CoreWLAN.CWMutableConfiguration.alloc().initWithConfiguration_(interfaces[i].configuration())
    # Find all the preferred/remembered network profiles
    profiles = list(configuration_copy.networkProfiles())
    # Grab all the SSIDs, in order
    SSIDs = [x.ssid() for x in profiles]
    # Loop through PreferredSSIDs list in reverse order sorting each entry to the front of profiles array so it
    # ends up sorted with PreferredSSIDs as the first items.
    # Order is preserved for other SSIDs, example where PreferredSSIDs is [ssid3, ssid4]:
    #    Original: [ssid1, ssid2, ssid3, ssid4]
    #   New order: [ssid3, ssid4, ssid1, ssid2]
    for aSSID in reversed(PreferredSSIDs):
        profiles.sort(key=lambda x: x.ssid() == aSSID, reverse=True)
    # Now we have to update the mutable configuration
    # First convert it back to a NSOrderedSet
    profile_set = NSOrderedSet.orderedSetWithArray_(profiles)
    # Then set/overwrite the configuration copy's networkProfiles
    configuration_copy.setNetworkProfiles_(profile_set)
    # Then update the network interface configuration
    result = interfaces[i].commitConfiguration_authorization_error_(configuration_copy, None, None)
