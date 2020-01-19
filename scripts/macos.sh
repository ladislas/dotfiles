#!/usr/bin/env zsh

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
try osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
try sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


###############################################################################
# General UI/UX
###############################################################################

echo "ee General UI/UX"

DATE=$(date +"%Y%m%d")
COMPUTER_NAME="LadBookPro$DATE"

echo "› Set computer name to $COMPUTER_NAME"
try sudo scutil --set ComputerName "$COMPUTER_NAME"
try sudo scutil --set HostName "$COMPUTER_NAME"
try sudo scutil --set LocalHostName "$COMPUTER_NAME"
try sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"

echo "› Always show scrollbars"
try defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

echo "› Expand save & printing panels by default"
try defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
try defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
try defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
try defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo "› Disable the over-the-top focus ring animation"
try defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

echo "› Save to disk (not to iCloud) by default"
try defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "› Automatically quit printer app once the print jobs complete"
try defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "› Set Help Viewer windows to non-floating mode"
try defaults write com.apple.helpviewer DevMode -bool true

echo "› Reveal IP address, hostname, OS version, etc. when clicking the clock" # in the login window
try sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo "› Disable automatic capitalization"
try defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

echo "› Disable smart dashes"
try defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "› Disable automatic period substitution"
try defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "› Disable smart quotes"
try defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false


###############################################################################
# General Power and Performance modifications
###############################################################################

echo "›› General Power and Performance modifications"

echo "› Disable Resume system-wide"
try defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

echo "› Disable automatic termination of inactive apps"echo " ›"
try defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

echo "› Disable the sudden motion sensor?"
sudo pmset -a sms 0

echo "› Speed up wake from sleep to 24 hours from an hour"
sudo pmset -a standbydelay 86400

echo "› Sleep the display after 15 minutes"
try sudo pmset -a displaysleep 15

echo "› Disable machine sleep while charging"
try sudo pmset -c sleep 0

echo "› Set machine sleep to 5 minutes on battery"
try sudo pmset -b sleep 5

echo "› Enable lid wakeup"
try sudo pmset -a lidwake 1


###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################

echo "›› Trackpad, mouse, keyboard, Bluetooth accessories, and input"

echo "› Increase sound quality for Bluetooth headphones/headsets"
try defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo "› Enable full keyboard access for all controls" # (e.g. enable Tab in modal dialogs)
try defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "› Trackpad: enable tap to click for this user and for the login screen"
try defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
try defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
try defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
try defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "› Set a blazingly fast keyboard repeat rate"
try defaults write NSGlobalDomain KeyRepeat -int 1
try defaults write NSGlobalDomain InitialKeyRepeat -int 10

echo "› Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300


###############################################################################
# Screen
###############################################################################

echo "›› Screen"

echo "› Require password immediately after sleep or screen saver begins"
try defaults write com.apple.screensaver askForPassword -int 1
try defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "› Save screenshots in PNG format" # (other options: BMP, GIF, JPG, PDF, TIFF)
try defaults write com.apple.screencapture type -string "png"

echo "› Enable subpixel font rendering on non-Apple LCDs"
try defaults write NSGlobalDomain AppleFontSmoothing -int 1

echo "› Enable HiDPI display modes (requires restart)"
try sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true


###############################################################################
# Finder
###############################################################################

echo "›› Finder"

echo "› Disable window animations and Get Info animations"
try defaults write com.apple.finder DisableAllAnimations -bool true

echo "› Show icons for hard drives, servers, and removable media on the desktop"
try defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
try defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
try defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
try defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo "› Finder: show all filename extensions"
try defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "› Finder: show status bar"
try defaults write com.apple.finder ShowStatusBar -bool true

echo "› Finder: show path bar"
try defaults write com.apple.finder ShowPathbar -bool true

echo "› Display full POSIX path as Finder window title"
try defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo "› Keep folders on top when sorting by name"
try defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo "› When performing a search, search the current folder by default"
try defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "› Enable spring loading for directories"
try defaults write NSGlobalDomain com.apple.springing.enabled -bool true

echo "› Remove the spring loading delay for directories"
try defaults write NSGlobalDomain com.apple.springing.delay -float 0

echo "Allowing text selection in Quick Look/Preview in Finder by default"
try defaults write com.apple.finder QLEnableTextSelection -bool true

echo "› Use colimn view in all Finder windows by default"
try defaults write com.apple.finder FXPreferredViewStyle Clmv

echo "› Avoid creating .DS_Store files on network or USB volumes"
try defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
try defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo "› Disable disk image verification"
try defaults write com.apple.frameworks.diskimages skip-verify -bool true
try defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
try defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

echo "› Show item info near icons on the desktop and in other icon views"
try /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

echo "› Enable snap-to-grid for icons on the desktop and in other icon views"
try /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

echo "› Increase grid spacing for icons on the desktop and in other icon views"
try /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

echo "› Show the ~/Library folder"
try chflags nohidden ~/Library

echo "› Show the /Volumes folder"
try sudo chflags nohidden /Volumes


###############################################################################
# Dock, Dashboard & Mission Control
###############################################################################

echo "›› Dock, Dashboard & Mission Control"

echo "› Wipe all (default) app icons from the Dock" # This is only really useful when setting up a new Mac
try defaults write com.apple.dock persistent-apps -array

echo "› Change position of the Dock to right" # Available options: "left" "right" or "bottom"
try defaults write com.apple.Dock orientation -string right

echo "› Enable highlight hover effect for the grid view of a stack (Dock)"
try defaults write com.apple.dock mouse-over-hilite-stack -bool true

echo "› Set the icon size of Dock items to 30 pixels"
try defaults write com.apple.dock tilesize -int 30

echo "› Change minimize/maximize window effect"
try defaults write com.apple.dock mineffect -string "genie"

echo "› Enable spring loading for all Dock items"
try defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

echo "› Show indicator lights for open applications in the Dock"
try defaults write com.apple.dock show-process-indicators -bool true

echo "› Minimize windows into their application’s icon"
try defaults write com.apple.dock minimize-to-application -bool true

echo "› Remove the auto-hiding Dock delay"
try defaults write com.apple.dock autohide -bool true
try defaults write com.apple.dock autohide-delay -float 0
try defaults write com.apple.dock autohide-time-modifier -float 0

echo "› Disable Dashboard"
try defaults write com.apple.dashboard mcx-disabled -bool true

echo "› Don’t show Dashboard as a Space"
try defaults write com.apple.dock dashboard-in-overlay -bool true

echo "› Don’t automatically rearrange Spaces based on most recent use"
try defaults write com.apple.dock mru-spaces -bool false


###############################################################################
# Hot corners
###############################################################################

echo "›› Hot corners"

echo "› Top left screen corner → Mission Control"
try defaults write com.apple.dock wvous-tl-corner -int 2
try defaults write com.apple.dock wvous-tl-modifier -int 0

echo "› Top right screen corner → Show application windows"
try defaults write com.apple.dock wvous-tr-corner -int 3
try defaults write com.apple.dock wvous-tr-modifier -int 0

echo "› Bottom left screen corner → Desktop"
try defaults write com.apple.dock wvous-bl-corner -int 4
try defaults write com.apple.dock wvous-bl-modifier -int 0

echo "› Bottom right screen corner → Desktop"
try defaults write com.apple.dock wvous-br-corner -int 4
try defaults write com.apple.dock wvous-br-modifier -int 0


###############################################################################
# Terminal
###############################################################################

echo "›› Terminal"

echo "› Enable UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
try defaults write com.apple.terminal StringEncodings -array 4
try defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
try defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

echo "› Enable Secure Keyboard Entry in Terminal.app" # See: https://security.stackexchange.com/a/47786/8918
try defaults write com.apple.terminal SecureKeyboardEntry -bool true

echo "› Disable the annoying line marks"
try defaults write com.apple.Terminal ShowLineMarks -int 0


###############################################################################
# Messages
###############################################################################

echo "›› Messages"

echo "› Disable smart quotes in Messages.app"
try defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false


###############################################################################
# Transmission.app
###############################################################################

echo "rr Transmission.app"

try mkdir -p ~/Torrentz/Incomplete

echo "› Setting up an incomplete downloads folder in Downloads"
try defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
try defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Torrentz/Incomplete"

echo "› "
echo "› Setting auto-add folder to be Downloads"
try defaults write org.m0k.transmission AutoImportDirectory -string "${HOME}/Torrentz"

echo "› "
echo "› Don't prompt for confirmation before downloading"
try defaults write org.m0k.transmission DownloadAsk -bool false

echo "› "
echo "› Trash original torrent files after adding them"
try defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

echo "› "
echo "› Hiding the donate message"
try defaults write org.m0k.transmission WarningDonate -bool false

echo "› "
echo "› Hiding the legal disclaimer"
try defaults write org.m0k.transmission WarningLegal -bool false

echo "› "
echo "› Auto-resizing the window to fit transfers"
try defaults write org.m0k.transmission AutoSize -bool true

echo "› "
echo "› Auto updating to betas"
try defaults write org.m0k.transmission AutoUpdateBeta -bool true

echo "› "
echo "› Setting up the best block list"
try defaults write org.m0k.transmission EncryptionRequire -bool true
try defaults write org.m0k.transmission BlocklistAutoUpdate -bool true
try defaults write org.m0k.transmission BlocklistNew -bool true
try defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"


###############################################################################
# Activity Monitor
###############################################################################

echo "›› Activity Monitor"

echo "› Show the main window when launching Activity Monitor"
try defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

echo "› Show all processes in Activity Monitor"
try defaults write com.apple.ActivityMonitor ShowCategory -int 0

echo "› Sort Activity Monitor results by CPU usage"
try defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
try defaults write com.apple.ActivityMonitor SortDirection -int 0


###############################################################################
# TextEdit & Disk Utility
###############################################################################

echo "›› TextEdit & Disk Utility"

echo "› Use plain text mode for new TextEdit documents"
try defaults write com.apple.TextEdit RichText -int 0

echo "› Open and save files as UTF-8 in TextEdit"
try defaults write com.apple.TextEdit PlainTextEncoding -int 4
try defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

echo "› Enable the debug menu in Disk Utility"
try defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
try defaults write com.apple.DiskUtility advanced-image-options -bool true


###############################################################################
# Mac App Store
###############################################################################

echo "›› Mac App Store"

echo "› Enable the automatic update check"
try defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

echo "› Check for software updates daily, not just once per week"
try defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "› Download newly available updates in background"
try defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

echo "› Install System data files & security updates"
try defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

echo "› Turn on app auto-update"
try defaults write com.apple.commerce AutoUpdate -bool true

echo "› Allow the App Store to reboot machine on macOS updates"
try defaults write com.apple.commerce AutoUpdateRestartRequired -bool true


###############################################################################
# Photos
###############################################################################

echo "›› Photos"

echo "› Prevent Photos from opening automatically when devices are plugged in"
try defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


###############################################################################
# Kill affected applications
###############################################################################

echo "☠️ Kill related apps"

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
	"Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
	"Terminal" "Transmission" "Photos" "Mac App Store" "Rectangle" ; do
	killall "$app" > /dev/null 2>&1
done

echo "🎉 Done! ✅ Note that some of these changes require a logout/restart to take effect"
