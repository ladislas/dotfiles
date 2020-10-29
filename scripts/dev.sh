#!/usr/bin/env zsh

print_action "Symlink to $HOME"
symlink=".editorconfig"
try ln -sr ./symlink/$symlink $HOME/$symlink


print_action "Create dev directory tree"
try mkdir -p $HOME/dev/{ladislas,leka,osx-cross,tmp}


print_action "Clone personal repositories"
cd $HOME/dev/ladislas
try git clone --recursive https://github.com/ladislas/Bare-Arduino-Project
try git clone --recursive https://github.com/ladislas/mbed-cmake-template
try git clone https://github.com/ladislas/explorations


print_action "Clone Leka repositories"
cd $HOME/dev/leka
try git clone --recursive https://github.com/leka/Arduino-Makefile
try git clone --recursive https://github.com/leka/leka-app
try git clone --recursive https://github.com/leka/LKAlphaOS
try git clone --recursive https://github.com/leka/LekaOS

try git clone https://github.com/leka/LekaOS.wiki.git
try git clone https://github.com/leka/LekaOS_Explorations
try git clone https://github.com/leka/styleguides


print_action "Clone osx-cross repositories"
cd $HOME/dev/osx-cross
try git clone https://github.com/osx-cross/homebrew-avr
try git clone https://github.com/osx-cross/homebrew-arm
try git clone https://github.com/osx-cross/homebrew-stm32


print_action "Symlink osx-cross formulae & casks"
clone_path="$HOME/dev/osx-cross"
tap_path="/usr/local/Homebrew/Library/Taps/osx-cross"

try mkdir -p /usr/local/Homebrew/Library/Taps/osx-cross
try ln -sfn $clone_path/homebrew-stm32 $tap_path/homebrew-stm32
try ln -sfn $clone_path/homebrew-avr $tap_path/homebrew-avr
try ln -sfn $clone_path/homebrew-arm $tap_path/homebrew-arm


print_action "Install osx-cross formulae & casks"
try brew install avr-gcc
try brew install arm-gcc-bin
try brew cask install stm32cubemx


print_action "Install useful gems, pip & node packages"
try gem install --no-document cocoapods fastlane neovim
try python3 -m pip install -U --user mbed-cli pyserial neovim pyocd
try npm install -g neovim
