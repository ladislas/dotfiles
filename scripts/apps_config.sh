#!/usr/bin/env zsh

# Continue on error
set +e

apps=( \
	"AppCleaner" \
	"CoolTerm" \
	"Fantastical" \
	"iTerm" \
	"MacDown" \
	"Rectangle" \
	"Sublime Text" \
	"Transmission" \
	"Visual Studio Code" \
	"Xcode" \
)


echo ""
echo "› Open applications before configuration"
for app in $apps; do
	try open -a "$app"
done

echo ""
echo "› Wait for apps to launch"
try sleep 3

echo ""
echo "› Kill applications before copying preferences"
for app in $apps; do
	if [[ $app =~ "iTerm" ]] ; then
		try killall iTerm2
	elif [[ $app =~ "Visual Studio Code" ]] ; then
		try osascript -e 'quit app "Visual Studio Code"'
	else
		try killall "${app}"
	fi
done


user_library_path="$HOME/Library"
dotf_library_path="./Library"

user_preferences_path="$user_library_path/Preferences"
dotf_preferences_path="$dotf_library_path/Preferences"

user_colors_path="$user_library_path/Colors"
dotf_colors_path="$dotf_library_path/Colors"

user_spelling_path="$user_library_path/Spelling"
dotf_spelling_path="$dotf_library_path/Spelling"

user_xcode_userdata_path="$user_library_path/Developer/Xcode/UserData"
dotf_xcode_userdata_path="$dotf_library_path/Developer/Xcode/UserData"

user_sublimetext_settings_path="$user_library_path/Application Support/Sublime Text 3/Packages/User"
dotf_sublimetext_settings_path="$dotf_library_path/Application Support/Sublime Text 3/Packages/User"

echo ""
echo "› Copy .plist to $user_preferences_path"
try cp -r $dotf_preferences_path/*.plist $user_preferences_path

echo ""
echo "› Copy .clr to $user_colors_path"
try cp -r $dotf_colors_path/*.clr $user_colors_path

echo ""
echo "› Copy dictionary to $user_spelling_path"
try cp -r $dotf_spelling_path/* $user_spelling_path

echo ""
echo "› Copy Xcode settings to $user_xcode_userdata_path"
try cp -r "$dotf_xcode_userdata_path/*" $user_xcode_userdata_path
# try cp -r $dotf_xcode_userdata_path/FontAndColorThemes/* $user_xcode_userdata_path/FontAndColorThemes
# try cp -r $dotf_xcode_userdata_path/KeyBindings/* $user_xcode_userdata_path/KeyBindings

echo ""
echo "› Copy Sublime Text settings to $user_sublimetext_settings_path"
try mkdir -p $user_sublimetext_settings_path
try cp -r $dotf_sublimetext_settings_path/* $user_sublimetext_settings_path

