#!/usr/bin/env zsh

# Continue on error
set +e

if ! is_ci ; then
	print_action "Update brew"
	try brew update
	try brew upgrade
fi

# List already available formulae
available_formulae=$(brew list)

typeset -U formulae
formulae=(
	# Install GNU core utilities (those that come with macOS are outdated)
	# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`
	coreutils
	# Install some other useful utilities like `sponge`
	# moreutils
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

	# Install git & co
	gh
	git
	git-lfs
	gitmoji
	git-crypt
	diff-so-fancy

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
	ninja
	openssh

	# Install useful tools
	ack
	tree
	neovim
	pandoc
	rename
	the_silver_searcher

	# Install dev tools
	lcov
	gcovr
	stlink
	ccache
	fastlane
	open-ocd
	swiftformat
	clang-format
)

print_action "Install formulae"
for formula in $formulae ; do
	if [[ ! $available_formulae =~ $formula ]]; then
		try_can_fail brew install $formula
	fi
done

if ! is_ci ; then
	print_action "Cleanup brew & remove cache"
	try brew cleanup -s
	try rm -rf "$(brew --cache)"
fi
