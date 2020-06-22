#!/usr/bin/env zsh

# Continue on error
set +e
if [[ ! -n $CI_TEST ]]; then
	echo ""
	echo "› Update brew"
	try brew update
	try brew upgrade
fi


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

if [[ ! -n $CI_TEST ]]; then
	echo ""
	echo "› Cleanup brew & remove cache"
	try brew cleanup -s
	try rm -rf "$(brew --cache)"
fi
