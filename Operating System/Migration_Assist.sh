#!/bin/bash

####################################################################################################
#
# CREATED BY
#
# 	Brian Stutzman
#
# DESCRIPTION
#
# 	This script is used to move/copy data from different locations on the HD into a single folder on
# 	the desktop for easy transferring to network shares, flash drives or OneDrive.  Use this workflow
# 	before re-imaging the user's computer.
#
#	- Apple Remote Desktop database and template files (if installed)
#	- Browser Bookmarks (Safari, Google Chrome, Firefox, if installed)
#	- Backup Connect to Servers favorites list
#	- Export a list of all installed apps
#	- Take screenshots of the login items and launchpad
#	- Move all files within the Downloads folder
#	- Move all files within the Documents folder
#	- Move all files within the Desktop folder
#	- Move all files within the Pictures folder
#
# 	NOTE: The user will have to approve the "JamfManagementService" app in "System Preferences > 
#	Privacy > Accessiblity". This can be automated by creating a PPPC profile to add this app to
#	Accessbility. Also need to allow AppleEvents "com.apple.systempreferences" to access this
#	application. Doing this the user will not be prompted to do anything while the script is running.
#
# 	This tool will be used to backup other important items in the future.
#
# VERSION
#
# 	- 1.4
#
# CHANGE HISTORY
#
# 	- Created script - 5/30/19 (1.0)
# 	- Made enhancements to the script, also added IF statements - 7/18/19 (1.1)
#	- Corrected the move to OneDrive option - 8/14/19 (1.2)
#	- Included the Pictures folder in the backup process - 11/1/19 (1.3)
#	- Added Music, Movies, Public folders to the script - 11/29/19 (1.4)
#
####################################################################################################


##################################################################
## Script variables (EDIT BELOW)
##################################################################

odFolderName="OneDrive"


##################################################################
## Script variables (DO NOT EDIT)
##################################################################

user=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
icon="/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/Assistant.icns"
icon2="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"


##################################################################
## Script functions
##################################################################

# Create the main directory on user's desktop
function MainDir ()
{
  mkdir /Users/$user/Desktop/BackupFiles

  # Change permissions on the Folder
  chmod -R 777 /Users/$user/Desktop/BackupFiles
}

# Copy the Apple Remote Desktop Files to the main backup folder
function ARDFiles ()
{
  # Check to see if the app is installed
  if [ -d "/Applications/Remote Desktop.app" ]; then

	echo "Script result: >> ARD Installed"
    
    # Create folder inside the main directory
	mkdir /Users/$user/Desktop/BackupFiles/AppleRemoteDesktop
    chmod -R 777 /Users/$user/Desktop/BackupFiles/AppleRemoteDesktop

	# Copy Apple Remote Desktop Presets folder
	cp -Rpv /Users/$user/Library/Containers/com.apple.RemoteDesktop/Data/Library/Application\ Support/Remote\ Desktop/Presets /Users/$user/Desktop/BackupFiles/AppleRemoteDesktop

	# Copy the Apple Remote Desktop database plist file
	cp -Rpv /Users/$user/Library/Containers/com.apple.RemoteDesktop/Data/Library/Preferences/com.apple.RemoteDesktop.plist /Users/$user/Desktop/BackupFiles/AppleRemoteDesktop

  else
	
	echo "Script result: >> ARD Not Installed"
	
  fi
}


# Copy the browser bookmarks to the main backup folder
function BrowserBookmarks ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/Browser-Bookmarks
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Browser-Bookmarks

  # Safari bookmarks
  mkdir /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/Safari
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/Safari

  osascript -e '
  tell application "Safari" to activate
  tell application "System Events" to tell process "Safari"
	click menu item "Export Bookmarks…" of menu 1 of menu bar item "File" of menu bar 1
    delay 1
	keystroke "d" using command down -- to save on the desktop
	click button "Save" of window 1
	if sheet 1 of window 1 exists then click button "Replace" of sheet 1 of window 1
  end tell
  '
  
  sleep 3

  # Close the System Preferences window
  osascript -e 'quit app "Safari"'

  mv /Users/$user/Desktop/Safari\ Bookmarks.html /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/Safari

  # Google Chrome bookmarks
  # Check to see if the app is installed
  if [ -d "/Applications/Google Chrome.app" ]; then

	echo "Script result: >> Google Chrome Installed"
    
	# Create folder inside the main directory
	mkdir /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/GoogleChrome
    chmod -R 777 /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/GoogleChrome
    
	# Copy bookmarks to the main directory
	cp -Rpv /Users/$user/Library/Application\ Support/Google/Chrome/Default/Bookmarks* /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/GoogleChrome

  else
	
	echo "Script result: >> Google Chrome Not Installed"
	
  fi

  # Firefox bookmarks
  # Check to see if the app is installed
  if [ -d "/Applications/Firefox.app" ]; then

	echo "Script result: >> Firefox Installed"
    
	# Create folder inside the main directory
	mkdir /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/Firefox
    chmod -R 777 /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/Firefox
	
	# Copy bookmarks to the main directory
    cp -Rpv /Users/$user/Library/Application\ Support/Firefox/Profiles /Users/$user/Desktop/BackupFiles/Browser-Bookmarks/Firefox

  else
	
	echo "Script result: >> Firefox Not Installed"
	
  fi
}


# Copy the Favorite Servers List to the main backup folder
function ConnectToServerList ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/FavServers
  chmod -R 777 /Users/$user/Desktop/BackupFiles/FavServers

  # Copy file into backup directory
  cp -Rpv /Users/$user/Library/Application\ Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.FavoriteServers.sfl2 /Users/$user/Desktop/BackupFiles/FavServers
}


# Take screenshots of the login items and Launchpad screens and transfer to the main backup folder
function ScreenShots ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/ScreenShots
  chmod -R 777 /Users/$user/Desktop/BackupFiles/ScreenShots

  # Open the Launchpad app
  open /Applications/Launchpad.app

  sleep 2

  # Take screenshot of Launchpad window
  screencapture -x /Users/$user/Desktop/BackupFiles/ScreenShots/launchpad.jpg

  # Open the Login Items window
  osascript -e '
  tell application "System Preferences"
	activate
	set the current pane to pane id "com.apple.preferences.users"
	get the name of every anchor of pane id "com.apple.preferences.users"
	--> returns: {"Main", "Spaces"}
	reveal anchor "startupItemsPref" of pane id "com.apple.preferences.users"
end tell
  '

  sleep 2

  # Take screenshot of login items
  screencapture -x /Users/$user/Desktop/BackupFiles/ScreenShots/login_items.jpg

  sleep 2

  # Close the System Preferences window
  osascript -e 'quit app "System Preferences"'
}


# Generate a list of all installed apps and move to the main backup folder
function AppsList ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/AppsList
  chmod -R 777 /Users/$user/Desktop/BackupFiles/AppsList

  # Generate a txt file of all installed apps
  ls /Applications > /Users/$user/Desktop/BackupFiles/AppsList/InstalledApps.txt
  ls /Applications/Utilities > /Users/$user/Desktop/BackupFiles/AppsList/InstalledApps_Utilities.txt
}


# Move all files in the Downloads folder to the main backup folder
function MoveDownloadFiles ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/Downloads-Folder
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Downloads-Folder

  # Move all files in the Downloads folder
  mv /Users/$user/Downloads/* /Users/$user/Desktop/BackupFiles/Downloads-Folder
}


# Move all files in the Pictures folder to the main backup folder
function MovePictureFiles ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/Pictures-Folder
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Pictures-Folder

  # Move all files in the Pictures folder
  mv /Users/$user/Pictures/* /Users/$user/Desktop/BackupFiles/Pictures-Folder
}


# Move all files in the Documents folder to the main backup folder
function MoveDocumentFiles ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/Documents-Folder
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Documents-Folder

  # Move all files in the Documents folder
  mv /Users/$user/Documents/* /Users/$user/Desktop/BackupFiles/Documents-Folder
}


# Move all files in the Music folder to the main backup folder
function MoveMusicFiles ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/Music-Folder
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Music-Folder

  # Move all files in the Music folder
  mv /Users/$user/Music/* /Users/$user/Desktop/BackupFiles/Music-Folder
}


# Move all files in the Movies folder to the main backup folder
function MoveMoviesFiles ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/Movies-Folder
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Movies-Folder

  # Move all files in the Movies folder
  mv /Users/$user/Movies/* /Users/$user/Desktop/BackupFiles/Movies-Folder
}


# Move all files in the Public folder to the main backup folder
function MovePublicFiles ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/Public-Folder
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Public-Folder

  # Move all files in the Public folder
  mv /Users/$user/Public/* /Users/$user/Desktop/BackupFiles/Public-Folder
}


# Move all files in the Desktop folder to the main backup folder
function MoveDesktopFiles ()
{
  # Create folder inside the main directory
  mkdir /Users/$user/Desktop/BackupFiles/Desktop-Folder
  chmod -R 777 /Users/$user/Desktop/BackupFiles/Desktop-Folder

  # Move "BackupFiles" folder to "/tmp"
  mv /Users/$user/Desktop/BackupFiles /tmp/

  # Move the desktop files to the "Desktop-Folder"
  mv /Users/$user/Desktop/* /tmp/BackupFiles/Desktop-Folder

  # Move the "BackupFiles" folder to the desktop
  mv /tmp/BackupFiles /Users/$user/Desktop/
}


# Change permissions on the BackupFiles folder
function ModifyPermissions ()
{
  chmod -R 777 /Users/$user/Desktop/BackupFiles
}


# Display closing message confirming files have been transfered to the main backup folder
function ClosingMessage ()
{
completeMessage=$("$jamfHelper" -windowType hud -lockHUD -title "Migration Assist" -heading "Completed!" \
-description "All files have been moved/copied to the BackupFiles folder on the desktop.  

Do you wish to keep the BackupFiles folder on the desktop or move it to the OneDrive folder?" \
-icon "$icon" -button1 "Desktop" -button2 "OneDrive" -defaultButton 0)

	if [ "$completeMessage" == "0" ]; then

		echo "Script result: >> User clicked Desktop."

		exit 0

	elif [ "$completeMessage" == "2" ]; then

		echo "Script result: >> User clicked OneDrive."
        
		# Check to see if the OneDrive folder exists
		if [ -d "/Users/$user/$odFolderName" ]; then

			echo "Script result: >> OneDrive folder found"
    		
        else
	
			echo "Script result: >> ERROR! OneDrive folder not found"
            
            "$jamfHelper" -windowType hud -lockHUD -title "Migration Assist" -heading "Error!" \
			-description "OneDrive folder not found.  
            
The BackupFiles folder will remain on the desktop." \
			-icon "$icon2" -button1 "QUIT" -defaultButton 0
            
            exit 0
        
        fi

		# Check to see if the OneDrive folder exists
		odDir=$(ls /Users/$user | grep -c "$odFolderName")
        if [ "$odDir" = "1" ]; then
            
            	echo "Script result: >> OneDrive folder found"
                
                # Move BackupFiles folder to OneDrive folder
				mv /Users/$user/Desktop/BackupFiles "/Users/$user/$odFolderName"

		else
	
			echo "Script result: >> ERROR! OneDrive folder not found"
            
            "$jamfHelper" -windowType hud -lockHUD -title "Migration Assist" -heading "Error!" \
			-description "OneDrive folder not found.  
            
The BackupFiles folder will remain on the desktop." \
			-icon "$icon2" -button1 "QUIT" -defaultButton 0
    
			exit 0
        
        fi

	fi
}


##################################################################
## Main script
##################################################################

# JAMF Helper window to inform what is being backed up provide choice of backup type
userChoice=$("$jamfHelper" -windowType hud -title "Migration Assist" -description "This script will move/copy the following into a single folder on the desktop for easy transferring to a network share or OneDrive.

- All files in the Downloads folder
- All files in the Documents folder
- All files in the Desktop folder
- All files in the Pictures folder
- ARD files (if installed)
- Browser bookmarks (Safari, Chrome, Firefox if installed)  
- Backup Connect to Servers favorites list
- Take screenshots of the login items and launchpad
- Export a list of all installed apps 

Do you wish to continue?" \
-icon "$icon" -button1 "YES" -button2 "QUIT" -defaultButton 0)

if [ "$userChoice" == "0" ]; then

        echo "User clicked YES."

        MainDir

        MoveDownloadFiles
        
        MovePictureFiles

        MoveDocumentFiles
        
        MoveMusicFiles
        
        MoveMoviesFiles
        
        MovePublicFiles

        MoveDesktopFiles

        ARDFiles

        BrowserBookmarks

        ConnectToServerList

        ScreenShots

        AppsList
        
        ModifyPermissions

        ClosingMessage

      elif [ "$userChoice" == "2" ]; then

        echo "User clicked QUIT."

		exit 0
fi


exit 0
