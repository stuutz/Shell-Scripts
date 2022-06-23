#!/bin/sh

####################################################################################################
#
# DESCRIPTION
#
#	This will create a bookmarks folder and add sites to the folder within Safari.
#	
#	NOTE: In order for this script to work Safari has to have at least one bookmark (to create the
#	bookmark file).  The script will fail if trying to run without any previously added bookmarks.
#
####################################################################################################


## Set variable for users over 500
over500=$(dscl . list /Users UniqueID | awk '$2 > 500 { print $1 }')

addBookmark() {
	LinkTitle=$1
	LinkURL=$2
	userName=$3
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:Children:0 dict"
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:Children:0:URIDictionary dict"
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:Children:0:URIDictionary:title string ${LinkTitle}"
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:Children:0:URLString string ${LinkURL}"
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:Children:0:WebBookmarkType string WebBookmarkTypeLeaf"
}

createFolder() {
	folderName=$1
	userName=$2
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0 dict"
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:Children array"
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:WebBookmarkType string WebBookmarkTypeList"
	/usr/libexec/PlistBuddy /Users/$userName/Library/Safari/Bookmarks.plist -c "Add :Children:1:Children:0:Title string ${folderName}"
}

# Run for each user
for i in $over500; do
	echo "Processing user $i"
	if [ ! "$(grep "<string>My Favorites</string>" /Users/$i/Library/Safari/Bookmarks.plist)" ]; then
		cp -Rp /Users/$i/Library/Safari/Bookmarks.plist /Users/$i/Library/Safari/Bookmarks.old.plist
		#zip /Users/$i/Library/Safari/BookmarksBackup.zip /Users/$i/Library/Safari/Bookmarks.plist
		echo "backup of bookmarks SUCCESSFUL for the $i account."
		createFolder "My Favorites" $i
		addBookmark "Google" "https://www.google.com/" $i
		addBookmark "Yahoo" "https://www.yahoo.com/" $i
		addBookmark "CNN" "https://www.cnn.com/" $i
	else
		echo "User $i appears to already have the My Favorites bookmark folder, skipping"
	fi
done

exit 0