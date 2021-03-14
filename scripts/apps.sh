#!/usr/bin/env zsh

# Continue on error
set +e

if ! is_ci ; then
	print_action "Update brew"
	try brew update
	try brew upgrade
fi

print_action "Tap homebrew/cask"
try brew tap homebrew/cask

# List already available casks
available_casks=$(brew list --cask)

typeset -U casks
casks=(
	1password
	# adoptopenjdk
	# aerial
	alfred
	appcleaner
	brave-browser
	coolterm
	dropbox
	fantastical
	# glance
	# google-chrome
	# gpg-suite-no-mail
	iterm2
	macdown
	rectangle
	slack
	# spotify
	stats
	sublime-text
	# transmission
	visual-studio-code
	# vlc
	# whatsapp
)

print_action "Install casks"
for cask in $casks; do
	if [[ ! $available_casks =~ $cask ]]; then
		try_can_fail brew cask install --no-quarantine $cask
	fi
done

if ! is_ci ; then
	print_action "Cleanup brew & remove cache"
	try brew cleanup -s
	try rm -rf "$(brew --cache)"
fi
