#!/usr/bin/env zsh

# Continue on error
set +e

echo ""
echo "› Update brew"
try brew update
try brew upgrade


# List already available casks
available_casks=$(brew cask list)

typeset -U casks
casks=(
	1password
	adoptopenjdk
	aerial
	alfred
	appcleaner
	arduino
	brave-browser
	coolterm
	dropbox
	fantastical
	glance
	google-chrome
	gpg-suite-no-mail
	iterm2
	macdown
	rectangle
	slack
	spotify
	sublime-text
	transmission
	visual-studio-code
	vlc
	whatsapp
)

echo ""
echo "› Install casks"
for cask in $casks; do
	if [[ ! $available_casks =~ $cask ]]; then
		try brew cask install $cask
	fi
done


echo ""
echo "› Cleanup brew & remove cache"
try brew cleanup -s
try rm -rf "$(brew --cache)"


apps=("Visual Studio Code" "Sublime Text" "iTerm" "Transmission" "MacDown" "Fantastical 2" "Rectangle")

echo ""
echo "› Open apps before configuration"
for app in apps; do
	ls /Applications | grep $app
	if [ $? -eq 0 ]; then
		try open -a "$app"
	else
		echo "\t- $app not yet installed"
	fi
done


echo ""
echo "› Kill applications before copying preferences"
for app in apps; do
	try killall "${app}"
done


echo ""
echo "› Copy apps settings & preferences"
preferences_path="$HOME/Library/Preferences"

app_preferences="org.m0k.transmission.plist"
app_preferences_path="$preferences_path/$app_preferences"
try rm -rf $app_preferences_path
try cp -r ./preferences/$app_preferences $app_preferences_path

app_preferences="com.uranusjr.macdown.plist"
app_preferences_path="$preferences_path/$app_preferences"
try rm -rf $app_preferences_path
try cp -r ./preferences/$app_preferences $app_preferences_path

app_preferences="CoolTerm_Prefs.plist"
app_preferences_path="$preferences_path/$app_preferences"
try rm -rf $app_preferences_path
try cp -r ./preferences/$app_preferences $app_preferences_path

app_preferences="com.knollsoft.Rectangle.plist"
app_preferences_path="$preferences_path/$app_preferences"
try rm -rf $app_preferences_path
try cp -r ./preferences/$app_preferences $app_preferences_path

app_preferences="com.googlecode.iterm2.plist"
app_preferences_path="$preferences_path/$app_preferences"
try rm -rf $app_preferences_path
try cp -r ./preferences/$app_preferences $app_preferences_path
