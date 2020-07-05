#!/usr/bin/env zsh

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
print_action "Quit System Preferences"
try osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
# sudo -v

# Keep-alive: update existing `sudo` time stamp until `macos.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# Open affected applications
###############################################################################

echo ""
echo "›››"
echo "››› Open affected applications"
echo "›››"

typeset -U macos_apps

macos_apps=(
	"Activity Monitor"
	"App Store"
	"Calendar"
	"Contacts"
	"Dock"
	"Finder"
	"Mail"
	"Messages"
	"Photos"
	"Safari"
	"SystemUIServer"
	"Terminal"
)

echo ""
for app in $macos_apps ; do
	try open -a "${app}"
done


###############################################################################
# General UI/UX
###############################################################################

echo ""
echo "›››"
echo "››› General UI/UX"
echo "›››"

DATE=$(date +"%Y%m%d")
COMPUTER_NAME="LadBookPro$DATE"

print_action "Set computer name to $COMPUTER_NAME"
try sudo scutil --set ComputerName "$COMPUTER_NAME"
try sudo scutil --set HostName "$COMPUTER_NAME"
try sudo scutil --set LocalHostName "$COMPUTER_NAME"
try sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"

print_action "Always show scrollbars"
try defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

print_action "Expand save & printing panels by default"
try defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
try defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
try defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
try defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# echo ""
# echo "› Disable the over-the-top focus ring animation"
# try defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

print_action "Save to disk (not to iCloud) by default"
try defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

print_action "Automatically quit printer app once the print jobs complete"
try defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

print_action "Set Help Viewer windows to non-floating mode"
try defaults write com.apple.helpviewer DevMode -bool true

print_action "Reveal IP address, hostname, OS version, etc. when clicking the clock" # in the login window
try sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

print_action "Disable automatic capitalization"
try defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

print_action "Disable smart dashes"
try defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

print_action "Disable automatic period substitution"
try defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

print_action "Disable smart quotes"
try defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false


###############################################################################
# General Power and Performance modifications
###############################################################################

echo ""
echo "›››"
echo "››› General Power and Performance modifications"
echo "›››"

print_action "Disable Resume system-wide"
try defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

print_action "Disable automatic termination of inactive apps"
try defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

print_action "Disable the sudden motion sensor?"
try sudo pmset -a sms 0

# echo ""
# echo "› Speed up wake from sleep to 24 hours from an hour"
# try sudo pmset -a standbydelay 86400

print_action "Sleep the display after 15 minutes"
try sudo pmset -a displaysleep 15

print_action "Disable machine sleep while charging"
try sudo pmset -c sleep 0

print_action "Set machine sleep to 5 minutes on battery"
try sudo pmset -b sleep 5

print_action "Enable lid wakeup"
try sudo pmset -a lidwake 1


###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################

echo ""
echo "›››"
echo "››› Trackpad, mouse, keyboard, Bluetooth accessories, and input"
echo "›››"

print_action "Increase sound quality for Bluetooth headphones/headsets"
try defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

print_action "Enable full keyboard access for all controls" # (e.g. enable Tab in modal dialogs)
try defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

print_action "Trackpad: enable tap to click for this user and for the login screen"
try defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
try defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
try defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
try defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# echo ""
# echo "› Set a blazingly fast keyboard repeat rate"
# try defaults write NSGlobalDomain KeyRepeat -int 2
# try defaults write NSGlobalDomain InitialKeyRepeat -int 15

print_action "Turn off keyboard illumination when computer is not used for 5 minutes"
try defaults write com.apple.BezelServices kDimTime -int 300


###############################################################################
# Screen
###############################################################################

echo ""
echo "›››"
echo "››› Screen"
echo "›››"

print_action "Require password immediately after sleep or screen saver begins"
try defaults write com.apple.screensaver askForPassword -int 1
try defaults write com.apple.screensaver askForPasswordDelay -int 0

print_action "Save screenshots in PNG format" # (other options: BMP, GIF, JPG, PDF, TIFF)
try defaults write com.apple.screencapture type -string "png"

print_action "Enable subpixel font rendering on non-Apple LCDs"
try defaults write NSGlobalDomain AppleFontSmoothing -int 1

print_action "Enable HiDPI display modes (requires restart)"
try sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true


###############################################################################
# Finder
###############################################################################

echo ""
echo "›››"
echo "››› Finder"
echo "›››"

print_action "Disable window animations and Get Info animations"
try defaults write com.apple.finder DisableAllAnimations -bool true

print_action "Show icons for hard drives, servers, and removable media on the desktop"
try defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
try defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
try defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
try defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

print_action "Finder: show all filename extensions"
try defaults write NSGlobalDomain AppleShowAllExtensions -bool true

print_action "Finder: show status bar"
try defaults write com.apple.finder ShowStatusBar -bool true

print_action "Finder: show path bar"
try defaults write com.apple.finder ShowPathbar -bool true

print_action "Display full POSIX path as Finder window title"
try defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

print_action "Keep folders on top when sorting by name"
try defaults write com.apple.finder _FXSortFoldersFirst -bool true

print_action "When performing a search, search the current folder by default"
try defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

print_action "Enable spring loading for directories"
try defaults write NSGlobalDomain com.apple.springing.enabled -bool true

print_action "Remove the spring loading delay for directories"
try defaults write NSGlobalDomain com.apple.springing.delay -float 0

# echo "Allowing text selection in Quick Look/Preview in Finder by default"
# try defaults write com.apple.finder QLEnableTextSelection -bool true

print_action "Use column view in all Finder windows by default"
try defaults write com.apple.finder FXPreferredViewStyle Clmv

print_action "Avoid creating .DS_Store files on network or USB volumes"
try defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
try defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

print_action "Disable disk image verification"
try defaults write com.apple.frameworks.diskimages skip-verify -bool true
try defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
try defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

print_action "Show item info near icons on the desktop and in other icon views"
try /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

print_action "Enable snap-to-grid for icons on the desktop and in other icon views"
try /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

print_action "Increase grid spacing for icons on the desktop and in other icon views"
try /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
try /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist

print_action "Show the ~/Library folder"
try chflags nohidden ~/Library

print_action "Show the /Volumes folder"
try sudo chflags nohidden /Volumes


###############################################################################
# Dock, Dashboard & Mission Control
###############################################################################

echo ""
echo "›››"
echo "››› Dock, Dashboard & Mission Control"
echo "›››"

print_action "Change position of the Dock to right" # Available options: "left" "right" or "bottom"
try defaults write com.apple.Dock orientation -string right

print_action "Enable highlight hover effect for the grid view of a stack (Dock)"
try defaults write com.apple.dock mouse-over-hilite-stack -bool true

print_action "Set the icon size of Dock items to 30 pixels"
try defaults write com.apple.dock tilesize -int 30

print_action "Change minimize/maximize window effect"
try defaults write com.apple.dock mineffect -string "genie"

print_action "Enable spring loading for all Dock items"
try defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

print_action "Show indicator lights for open applications in the Dock"
try defaults write com.apple.dock show-process-indicators -bool true

# echo ""
# echo "› Minimize windows into their application’s icon"
# try defaults write com.apple.dock minimize-to-application -bool true

print_action "Remove the auto-hiding Dock delay"
try defaults write com.apple.dock autohide -bool true
try defaults write com.apple.dock autohide-delay -float 0
try defaults write com.apple.dock autohide-time-modifier -float 0

print_action "Disable Dashboard"
try defaults write com.apple.dashboard mcx-disabled -bool true

print_action "Don’t show Dashboard as a Space"
try defaults write com.apple.dock dashboard-in-overlay -bool true

print_action "Don’t automatically rearrange Spaces based on most recent use"
try defaults write com.apple.dock mru-spaces -bool false


###############################################################################
# Hot corners
###############################################################################

echo ""
echo "›››"
echo "››› Hot corners"
echo "›››"

print_action "Top left screen corner → Mission Control"
try defaults write com.apple.dock wvous-tl-corner -int 2
try defaults write com.apple.dock wvous-tl-modifier -int 0

print_action "Top right screen corner → Show application windows"
try defaults write com.apple.dock wvous-tr-corner -int 3
try defaults write com.apple.dock wvous-tr-modifier -int 0

print_action "Bottom left screen corner → Desktop"
try defaults write com.apple.dock wvous-bl-corner -int 4
try defaults write com.apple.dock wvous-bl-modifier -int 0

print_action "Bottom right screen corner → Desktop"
try defaults write com.apple.dock wvous-br-corner -int 4
try defaults write com.apple.dock wvous-br-modifier -int 0


###############################################################################
# Terminal
###############################################################################

echo ""
echo "›››"
echo "››› Terminal"
echo "›››"

print_action "Enable UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
try defaults write com.apple.terminal StringEncodings -array 4
try defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
try defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

print_action "Enable Secure Keyboard Entry in Terminal.app" # See: https://security.stackexchange.com/a/47786/8918
try defaults write com.apple.terminal SecureKeyboardEntry -bool true

print_action "Disable the annoying line marks"
try defaults write com.apple.Terminal ShowLineMarks -int 0


###############################################################################
# Messages
###############################################################################

echo ""
echo "›››"
echo "››› Messages"
echo "›››"

print_action "Disable smart quotes in Messages.app"
try defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false


###############################################################################
# Activity Monitor
###############################################################################

echo ""
echo "›››"
echo "››› Activity Monitor"
echo "›››"

print_action "Show the main window when launching Activity Monitor"
try defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

print_action "Show all processes in Activity Monitor"
try defaults write com.apple.ActivityMonitor ShowCategory -int 0

print_action "Sort Activity Monitor results by CPU usage"
try defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
try defaults write com.apple.ActivityMonitor SortDirection -int 0


###############################################################################
# TextEdit & Disk Utility
###############################################################################

echo ""
echo "›››"
echo "››› TextEdit & Disk Utility"
echo "›››"

print_action "Use plain text mode for new TextEdit documents"
try defaults write com.apple.TextEdit RichText -int 0

print_action "Open and save files as UTF-8 in TextEdit"
try defaults write com.apple.TextEdit PlainTextEncoding -int 4
try defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

print_action "Enable the debug menu in Disk Utility"
try defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
try defaults write com.apple.DiskUtility advanced-image-options -bool true


###############################################################################
# Mac App Store
###############################################################################

echo ""
echo "›››"
echo "››› Mac App Store"
echo "›››"

print_action "Enable the automatic update check"
try defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

print_action "Check for software updates daily, not just once per week"
try defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

print_action "Download newly available updates in background"
try defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

print_action "Install System data files & security updates"
try defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

print_action "Turn on app auto-update"
try defaults write com.apple.commerce AutoUpdate -bool true

print_action "Allow the App Store to reboot machine on macOS updates"
try defaults write com.apple.commerce AutoUpdateRestartRequired -bool true


###############################################################################
# Photos
###############################################################################

echo ""
echo "›››"
echo "››› Photos"
echo "›››"

print_action "Prevent Photos from opening automatically when devices are plugged in"
try defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


###############################################################################
# Kill affected applications
###############################################################################

echo ""
echo "›››"
echo "››› Kill affected applications"
echo "›››"

echo ""
for app in $macos_apps ; do
	try killall "${app}"
done
try killall "cfprefsd"
