#!/usr/bin/env zsh

#
# Source helper functions
#

source ./scripts/helpers.sh

#
# Set output level (verbose / super_verbose)
#

if [[ "$1" =~ "-vv" ]]; then
	alias try='try -vv'
	shift
elif [[ "$1" =~ "-v" || "$1" =~ "--verbose" ]]; then
	alias try='try -v'
	shift
fi

#
# Set arguments
#

arg_array=($@)
main_commands=("--all" "--force" "--test")
script_commands=("--hello" "--macos" "--brew" "--zsh" "--git" "--symlink" "--nvim" "--dev" "--data" "--gem-pip")
available_args=( ${main_commands[*]} ${script_commands[*]} )
test_commands=("--macos" "--zsh" "--git" "--symlink" "--nvim" "--dev" "--data")


#
# Check that arguments have been passed, if not exit
#

if [ ${#arg_array[@]} -eq 0 ]; then
	echo "⚠️ No arguments have been passed."
	echo "Please try again with one of those: $available_args"
	return 1
fi

#
# Check that passed arguments are available, if not exit
#

for arg in $arg_array; do
	if [[ ! " ${available_args[@]} " =~ " ${arg} " ]]; then
		echo "💥 Unrecognized argument: $arg"
		echo "Please try again with one of those: $available_args"
		return 1
	fi
done

#
# Check for brew & coreutils, if not install
#

if [[ $(command -v brew) == "" ]]; then
    echo "👷 Installing brew & coreutils 🚧"
    try /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    try brew install coreutils
elif [[ $(command -v gls) == "" ]]; then
	echo "👷 Installing coreutils 🚧"
	try brew install coreutils
fi

if [ ! $? -eq 0 ]; then
	echo "💥 Could not install brew & coreutils, exiting with status code $?"
	exit 1
fi

export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

#
# Arg: --all
#

if [[ $arg_array =~ "--all" ]]; then
	if [[ ! $arg_array =~ "--force" ]]; then
		echo "⚠️ You are about to run all the scripts. Please confirm that you have read\nthe source files and are okay with that. Unexepected behaviors can occur!"
		read "?Are you sure you want to continue? "
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
			[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
		fi
	fi

	echo "\n⚠️ Running bootstrap with all args!"
	arg_array=($script_commands)
fi

#
# Arg: --test
#

if [[ $arg_array =~ "--test" ]]; then
	echo "\n⚠️ Running bootstrap with all args except for testing!"
	arg_array=($test_commands)
	try false
fi

#
# Sudo power
#

if [[ $arg_array =~ "--macos" || $arg_array =~ "--brew" ]]; then
	if ! sudo -n true 2>/dev/null; then
		echo "⚠️ Args --macos & --brew require sudo to run."
		echo "Please enter your password."
		sudo -v
	fi
fi

#
# Arg: --hello
#

if [[ $arg_array =~ "--hello" ]]; then
	echo "Hello, World!"
fi

#
# Arg: --brew
#

if [[ $arg_array =~ "--brew" ]]; then
	echo "\n👷 Running brew configuration script 🚧\n"
	source ./scripts/brew.sh
fi

#
# Arg: --macos
#

if [[ $arg_array =~ "--macos" ]]; then
	echo "\n👷 Running macOS configuration script 🚧\n"

	echo "Opening apps before configuring"
	for app in "Visual Studio Code" "Sublime Text" "iTerm" \
	    "Transmission" "Fantastical\ 2" "Rectangle" ; do
		try open -a "$app"
	done

	source ./scripts/macos.sh
fi

#
# Arg: --zsh
#

if [[ $arg_array =~ "--zsh" ]]; then
	echo "\n👷 Running zsh configuration script 🚧\n"

	# Switch to using brew-installed zsh as default shell
	if ! fgrep -q "${BREW_PREFIX}/bin/zsh" /etc/shells; then
		echo ""
		echo "Setting brew zsh as default shell"
		try echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells;
		try chsh -s "${BREW_PREFIX}/bin/zsh";
	fi;

	try rm -f ~/.zcompdump
	try rm -f ./zsh/.zcompdump
	try rm -f ./zsh/.zcompdump.zwc

	try chmod go-w '/usr/local/share'

	try ln -sr ./symlink/.zshenv $HOME/.zshenv
	try mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}
	try ln -sr ./zsh ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Arg: --git
#

if [[ $arg_array =~ "--git" ]]; then
	echo "\n👷 Running git configuration script 🚧\n"
	try ln -sr ./git ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Arg: --neovim
#

if [[ $arg_array =~ "--nvim" ]]; then
	echo "\n👷 Running neovim configuration script 🚧\n"
	try git clone --recursive https://github.com/ladislas/nvim ~/.config/nvim
fi

#
# Arg: --data
#

if [[ $arg_array =~ "--data" ]]; then
	echo "\n👷 Running XGD Data configuration script 🚧\n"
	try mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}
	try ln -sr ./data/* ${XDG_DATA_HOME:-$HOME/.local/share}
fi

#
# Arg: --dev
#

if [[ $arg_array =~ "--dev" ]]; then
	echo "\n👷 Running dev directory structure configuration script 🚧\n"
	try mkdir -p $HOME/dev/{ladislas,leka,osx-cross,tmp}
fi

#
# Arg: --gem-pip
#

if [[ $arg_array =~ "--gem-pip" ]]; then
	echo "\n👷 Installing useful gems, pip & node packages 🚧\n"
	try gem install --no-document cocoapods fastlane neovim
	try pip install -U --user mbed-cli pyserial neovim
	try npm install -g neovim
fi

#
# List failed commands
#

list_failed_commands
