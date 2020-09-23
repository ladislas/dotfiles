#!/usr/bin/env zsh

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

print_action "Copy back .plist to $dotf_preferences_path"
for file in $dotf_preferences_path/* ; do
	f="$(basename -- $file)"
	try_can_fail cp -rf "$user_preferences_path/$f" "$dotf_preferences_path"
done

#
# Colors
#

print_action "Copy back Colors to $dotf_colors_path"
for file in $user_colors_path/* ; do
	f="$(basename -- $file)"
	try_can_fail cp -rf "$user_colors_path/$f" "$dotf_colors_path"
done

#
# Services
#

print_action "Copy back Services to $dotf_services_path"
for file in $user_services_path/* ; do
	f="$(basename -- $file)"
	try_can_fail cp -rf "$user_services_path/$f" "$dotf_services_path"
done

#
# Spelling
#

print_action "Copy back Spelling to $dotf_spelling_path"
for file in $dotf_spelling_path/* ; do
	f="$(basename -- $file)"
	try_can_fail cp -rf "$user_spelling_path/$f" "$dotf_spelling_path"
done

#
# Xcode
#

print_action "Copy back Xcode settings to $dotf_xcode_userdata_path"
for file in $dotf_xcode_userdata_path/* ; do
	f="$(basename -- $file)"
	try_can_fail cp -rf "$user_xcode_userdata_path/$f" "$dotf_xcode_userdata_path"
done

#
# Sublime Text
#

print_action "Copy back Sublime Text settings to $dotf_sublimetext_settings_path"
for file in $dotf_sublimetext_settings_path/Packages/User/* ; do
	f="$(basename -- $file)"
	try_can_fail cp -rf "$user_sublimetext_settings_path/Packages/User/$f" "$dotf_sublimetext_settings_path""
done
