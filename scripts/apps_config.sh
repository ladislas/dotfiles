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

print_action "Open applications before configuration"
for app in $user_apps; do
	if ls /Applications | grep "$app" &> /dev/null ; then
		try open -a "$app"
	fi
done

print_action "Wait for apps to launch"
try sleep 3

print_action "Kill applications before copying preferences"
for app in $user_apps; do
	if ls /Applications | grep "$app" &> /dev/null ; then
		if [[ $app =~ "iTerm" ]] ; then
			try killall iTerm2
		elif [[ $app =~ "Visual Studio Code" ]] ; then
			try osascript -e 'quit app "Visual Studio Code"'
		else
			try killall "${app}"
		fi
	fi
done

# Set path variables for all the preferences/settings
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

print_action "Rsync .plist to $user_preferences_path"
try mkdir -p $user_preferences_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Preferences" $dotf_preferences_path/ $user_preferences_path

print_action "Rsync Colors to $user_colors_path"
try mkdir -p $user_colors_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Colors" $dotf_colors_path/ $user_colors_path

print_action "Rsync Services to $user_colors_path"
try mkdir -p $user_services_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Services" $dotf_services_path/ $user_services_path

print_action "Rsync dictionary to $user_spelling_path"
try mkdir -p $user_spelling_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Spelling" $dotf_spelling_path/ $user_spelling_path

print_action "Rsync Xcode settings to $user_xcode_userdata_path"
try mkdir -p $user_xcode_userdata_path
try rsync -av --backup --backup-dir="$rsync_backup_path/Xcode" $dotf_xcode_userdata_path/ $user_xcode_userdata_path

print_action "Rsync Sublime Text settings to $user_sublimetext_settings_path"
try mkdir -p $user_sublimetext_settings_path
try rsync -av --backup --backup-dir="$rsync_backup_path/ST3" $dotf_sublimetext_settings_path/ $user_sublimetext_settings_path
