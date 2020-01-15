#!/usr/bin/env zsh

# Continue on error
set +e

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

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
	epenssh

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
	echo $formula
	brew install $formula
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
	echo $cask
	brew cask install $cask
done

# Install useful taps
brew tap osx-cross/arm
brew install arm-gcc-bin
brew tap osx-cross/avr
brew install avr-gcc
brew install avrdude

# Remove outdated versions from the cellar.
brew cleanup
