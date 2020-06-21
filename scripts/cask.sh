#!/usr/bin/env zsh

# Continue on error
set +e

# Make sure we’re using the latest Homebrew.
try brew update

# Upgrade any already-installed formulae.
try brew upgrade

# List already available casks
available_casks=$(brew cask list)

typeset -U casks
casks=(
	1password
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

# Install casks
for cask in $casks; do
	if [[ ! $available_casks =~ $cask ]]; then
		try brew cask install $cask
	fi
done

# Remove outdated versions from the cellar
try brew cleanup -s
try rm -rf "$(brew --cache)"

echo ""
echo "Opening apps before configuring"
for app in \
	"Visual Studio Code" \
	"Sublime Text" \
	"iTerm" \
    "Transmission" \
    "Fantastical 2" \
    "Rectangle" ;
do
	ls /Applications | grep $app
	if [ $? -eq 0 ]; then
		try open -a "$app"
	else
		echo "\t- $app not yet installed"
	fi
done

echo ""

###############################################################################
# Transmission.app
###############################################################################

echo ""
echo "›››"
echo "››› Transmission.app"
echo "›››"

try mkdir -p ~/Torrentz/Incomplete

echo ""
echo "› Setting up an incomplete downloads folder in Downloads"
try defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
try defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Torrentz/Incomplete"

echo ""
echo "› Setting auto-add folder to be Downloads"
try defaults write org.m0k.transmission AutoImportDirectory -string "${HOME}/Downloads"

echo ""
echo "› Setting download folder to be Torrentz"
defaults read org.m0k.transmission DownloadFolder -string "${HOME}/Torrentz"

echo ""
echo "› Don't prompt for confirmation before downloading"
try defaults write org.m0k.transmission DownloadAsk -bool false

echo ""
echo "› Trash original torrent files after adding them"
try defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

echo ""
echo "› Hiding the donate message"
try defaults write org.m0k.transmission WarningDonate -bool false

echo ""
echo "› Hiding the legal disclaimer"
try defaults write org.m0k.transmission WarningLegal -bool false

echo ""
echo "› Auto-resizing the window to fit transfers"
try defaults write org.m0k.transmission AutoSize -bool true

echo ""
echo "› Auto updating to betas"
try defaults write org.m0k.transmission AutoUpdateBeta -bool true

echo ""
echo "› Setting up the best block list"
try defaults write org.m0k.transmission EncryptionRequire -bool true
try defaults write org.m0k.transmission BlocklistAutoUpdate -bool true
try defaults write org.m0k.transmission BlocklistNew -bool true
try defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"


echo ""
echo "☠️ Kill related apps"

for app in \
	"Activity\ Monitor" \
	"Address\ Book" \
	"Calendar" \
	"Contacts" \
	"cfprefsd" \
	"Dock" \
	"Finder" \
	"Mail" \
	"Messages" \
	"Safari" \
	"SystemUIServer" \
	"Terminal" \
	"Transmission" \
	"Photos" \
	"App\ Store" \
	"Rectangle" ; do
	try killall "${app}" &> /dev/null
done

echo ""
echo "🎉 Done! ✅ Note that some of these changes require a logout/restart to take effect"
