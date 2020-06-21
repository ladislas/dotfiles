#!/usr/bin/env zsh

try mkdir -p $HOME/dev/{ladislas,leka,osx-cross,tmp}



	echo "\n👷 Installing useful gems, pip & node packages 🚧\n"
	try gem install --no-document cocoapods fastlane neovim
	try pip install -U --user mbed-cli pyserial neovim
	try npm install -g neovim