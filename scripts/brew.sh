#!/usr/bin/env zsh

# Continue on error
set +e

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
try brew update

# Upgrade any already-installed formulae.
try brew upgrade

# List already available formulae & casks
available_formulae=$(brew list)
available_casks=$(brew cask list)

typeset -U formulae
formulae=(
	# Install GNU core utilities (those that come with macOS are outdated)
	# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`
	coreutils
	# Install some other useful utilities like `sponge`
	moreutils
	# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
	findutils
	# Install macOS utils
	osxutils

	# Install a modern version of Bash
	bash

	# Install a modern version of Zsh
	zsh
	zsh-completion
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-history-substring-search

	# Brew
	brew-cask-completion

	# Install git & co
	hub
	git
	git-lfs
	github/gh/gh
	git-flow-avh
	diff-so-fancy
	mercurial

	# Install wget & curl
	wget
	curl

	# Install scripting languagues
	node
	ruby
	python

	# Install more recent versions of some macOS tools
	vim
	grep
	make
	cmake
	screen
	openssh

	# Install useful tools
	ack
	mint
	tree
	neovim
	pandoc
	rename
	imagemagick
	youtube-dl
	the_silver_searcher

	# Install dev tools
	avrdude
	stlink
	open-ocd
	swiftlint
	clang-format
	cppcheck

	# Install osx-cross formulae
	osx-cross/arm/arm-gcc-bin
	osx-cross/avr/avr-gcc
)

# Install formulae
for formula in $formulae ; do
	if [[ ! $available_formulae =~ $formula ]]; then
		try brew install $formula
	fi
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
	# font-source-code-pro
	google-chrome
	gpg-suite-no-mail
	iterm2
	macdown
	# mactex-no-gui
	qlcolorcode
	qlimagesize
	qlmarkdown
	qlprettypatch
	qlstephen
	quicklook-csv
	quicklook-json
	rectangle
	slack
	spotify
	sublime-text
	transmission
	# the-unarchiver
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
