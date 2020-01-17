#!/usr/bin/env zsh

# Continue on error
set +e

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
try brew update

# Upgrade any already-installed formulae.
try brew upgrade

typeset -U formulae
formulae=(
	# Install GNU core utilities (those that come with macOS are outdated).
	# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
	coreutils
	# Install some other useful utilities like `sponge`.
	moreutils
	# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
	findutils
	# Install macOS utils
	osxutils

	# Install a modern version of Bash.
	bash

	# Install a modern version of Zsh.
	zsh
	zsh-completion
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-history-substring-search

	# Brew
	brew-cask-completion

	# Install git & co.
	git
	hub
	git-lfs
	git-flow-avh
	mercurial

	# Install wget & curl
	wget
	curl

	# Install GnuPG to enable PGP-signing commits.
	# gnupg
	# pinentry

	# Install scripting languagues
	node
	ruby
	python

	# Install more recent versions of some macOS tools.
	vim
	grep
	make
	cmake
	screen
	openssh

	# Install other useful binaries.
	ack
	mint
	tree
	# mackup
	neovim
	pandoc
	rename
	stlink
	swiftlint
	imagemagick
	youtube-dl
	the_silver_searcher
)

# Install formulae
for formula in $formulae ; do
	try brew install $formula
done

typeset -U casks
casks=(
	1password
	alfred
	appcleaner
	arduino
	brave-browser
	coolterm
	dropbox
	fantastical
	google-chrome
	gpg-suite-no-mail
	iterm2
	macdown
	mactex-no-gui
	slack
	rectangle
	spotify
	sublime-text
	the-unarchiver
	visual-studio-code
	vlc
	whatsapp
)

# Install casks
for cask in $casks; do
	try brew cask install $cask
done

# Install useful taps
try brew tap osx-cross/arm
try brew install arm-gcc-bin
try brew tap osx-cross/avr
try brew install avr-gcc
try brew install avrdude

# Remove outdated versions from the cellar.
try brew cleanup -s
try rm -rf "$(brew --cache)"
