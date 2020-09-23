#!/usr/bin/env zsh

# Continue on error
set +e

typeset -U user_apps

user_apps=(
	"AppCleaner"
	"CoolTerm"
	"Fantastical"
	"iTerm"
	"MacDown"
	"Rectangle"
	"Sublime Text"
	"Transmission"
	"Visual Studio Code"
	"Xcode"
)

#
# Open apps
#

print_action "Open applications before configuration"
for app in $user_apps; do
	if ls /Applications | grep "$app" &> /dev/null ; then
		try open -a "$app"
	fi
done

#
# Wait and ask to continue when apps are open
#

echo ""
echo "› Wait for apps to launch"
try sleep 10

echo ""
echo "› Make sure all the apps have launched and that you've accepted any system dialog before moving forward"
echo ""
printf "👀 Are you ready to continue? (y/n) "
if ! is_ci ; then
	read
	if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
		echo ""
		echo "Goodbye, come again!..."
		exit 0
	fi
fi

#
# Close apps
#

print_action "Kill applications before copying preferences"
for app in $user_apps; do
	if ls /Applications | grep "$app" &> /dev/null ; then
		if [[ $app =~ "iTerm" ]] ; then
			try_can_fail killall iTerm2
		elif [[ $app =~ "Visual Studio Code" ]] ; then
			try_can_fail osascript -e 'quit app "Visual Studio Code"'
		else
			try_can_fail killall "${app}"
		fi
	fi
done

echo ""
echo "› Wait for apps to quit"
try sleep 10

#
# Set path variables for all the preferences/settings
#

user_library_path="$HOME/Library"
dotf_library_path="$DOTFILES_DIR/Library"
rsync_backup_path="$DOTFILES_DIR/Library/_backup"

user_preferences_path="$user_library_path/Preferences"
dotf_preferences_path="$dotf_library_path/Preferences"

user_colors_path="$user_library_path/Colors"
dotf_colors_path="$dotf_library_path/Colors"

user_services_path="$user_library_path/Services"
dotf_services_path="$dotf_library_path/Services"

user_spelling_path="$user_library_path/Spelling"
dotf_spelling_path="$dotf_library_path/Spelling"

user_xcode_userdata_path="$user_library_path/Developer/Xcode/UserData"
dotf_xcode_userdata_path="$dotf_library_path/Developer/Xcode/UserData"

user_sublimetext_settings_path="$user_library_path/Application Support/Sublime Text 3"
dotf_sublimetext_settings_path="$dotf_library_path/Application Support/Sublime Text 3"

#
# Preferences
#

print_action "Rsync .plist to $user_preferences_path"
try mkdir -p $user_preferences_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Preferences" $dotf_preferences_path/ $user_preferences_path

#
# Colors
#

print_action "Rsync Colors to $user_colors_path"
try mkdir -p $user_colors_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Colors" $dotf_colors_path/ $user_colors_path

#
# Services
#

print_action "Rsync Services to $user_colors_path"
try mkdir -p $user_services_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Services" $dotf_services_path/ $user_services_path

#
# Spelling
#

print_action "Rsync Spelling to $user_spelling_path"
try mkdir -p $user_spelling_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Spelling" $dotf_spelling_path/ $user_spelling_path

#
# Xcode
#

print_action "Rsync Xcode settings to $user_xcode_userdata_path"
try mkdir -p $user_xcode_userdata_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Xcode" $dotf_xcode_userdata_path/ $user_xcode_userdata_path

#
# Sublime Text
#

print_action "Rsync Sublime Text settings to $user_sublimetext_settings_path"
try mkdir -p $user_sublimetext_settings_path
try rsync -av --backup --backup-dir="$rsync_backup_path/ST3" $dotf_sublimetext_settings_path/ $user_sublimetext_settings_path

#
# Dock
#

# print_action "Wipe all (default) app icons from the Dock" # This is only really useful when setting up a new Mac
# try defaults write com.apple.dock persistent-apps -array

# print_action "Add favorite apps to Dock"
# function add_app_to_dock {
# 	app=$@
# 	try defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
# }
# add_app_to_dock "/Applications/Brave Browser Beta.app"
# add_app_to_dock "/System/Applications/Music.app"
# add_app_to_dock "/Applications/Slack.app"
# add_app_to_dock "/Applications/iTerm.app"
# add_app_to_dock "/System/Applications/System Preferences.app"

#
# Kill all for changes to take effect
#

print_action "Kill Dock for changes to take effect"
try_can_fail killall Dock

if ! is_ci ; then
	print_action "Kill Touch Bar for changes to take effect"
	try_can_fail sudo pkill "Touch Bar agent";
	try_can_fail sudo killall "ControlStrip";
fi
