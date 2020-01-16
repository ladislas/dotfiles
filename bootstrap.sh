#!/usr/bin/env zsh

# # Symlink files in $HOME

# # Install config
# typeset -U config_dirs
# config_dirs=(
# 	git
# 	zsh
# )

#
# Helpers
#

function try {
	if [[ "$@" =~ "sudo -v" ]]; then
		return 0
	fi 

	tmp_file=$(mktemp)

	echo -ne "Running $@ ... "

	script -q $tmp_file $@ > /dev/null 2>&1

	result=$?

	if [ $result -eq 0 ]; then
		echo "✅"
		#cat $tmp_file
	else
		echo "❌"
		cat $tmp_file
		echo ""
	fi

	rm -rf $tmp_file
}

export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

#
# Arguments
#

arg_array=($@)
main_commands=("--all" "--force" "--test")
script_commands=("--hello" "--macos" "--brew" "--zsh" "--git" "--symlink" "--nvim" "--dev" "--data" "--gem-pip")
available_args=( ${main_commands[*]} ${script_commands[*]} )
test_commands=("--brew" "--gem-pip" "--macos" "--zsh" "--git" "--symlink" "--nvim" "--dev" "--data")

#
# Check if arguments have been passed
#

if [ ${#arg_array[@]} -eq 0 ]; then
	echo "⚠️  No arguments have been passed."
	echo "Please try again with one of those: $available_args"
	return 1
fi

#
# Run everything with --all
#

if [[ "$arg_array" =~ "--all" ]]; then
	if [[ ! "$arg_array" =~ "--force" ]]; then
		echo "⚠️  You are about to run all the scripts. Please confirm that you have read\nthe source files and are okay with that. Unexepected behaviors can occur!"
		read "?Are you sure you want to continue? "
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
			[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
		fi
	fi

	echo "\n⚠️  Running all install scripts!"
	arg_array=($script_commands)
fi


#
# Test scripts
#

if [[ "$arg_array" =~ "--test" ]]; then
	echo "⚠️  Running all scripts except --brew, --gem-pip for testing!"
	arg_array=($test_commands)
fi

#
# Check if all arguments exist, if not exit
#

for arg in $arg_array; do
	if [[ ! " ${available_args[@]} " =~ " ${arg} " ]]; then
		echo "💥  Unrecognized argument: $arg"
		echo "Please try again with one of those: $available_args"
		return 1
	fi
done

#
# Sudo power
#

if [[ "$arg_array" =~ "--macos" || "$arg_array" =~ "--brew" ]]; then
	if ! sudo -n true 2>/dev/null; then
		echo "⚠️  Please enter your password as some scripts require sudo access."
		sudo -v
	fi
fi

#
# Hello, World! -- test argument
#

if [[ "$arg_array" =~ "--hello" ]]; then
	echo "Hello, World!"
	# if [[ ! "$arg_array" =~ "--force" ]]; then
	# 	read "?Are you sure you want to continue? "
	# 	if [[ ! $REPLY =~ ^[Yy]$ ]]
	# 	then
	# 		[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
	# 	fi
	# fi
	# try ls -al $HOME
	# try ls -al $HOME/null
fi

#
# macOS
#

if [[ "$arg_array" =~ "--macos" ]]; then
	echo "\n👷 Running macOS configuration script 🚧\n"

	# Set macOS defaults
	zsh ./scripts/macos.sh
fi

#
# Brew
#

if [[ "$arg_array" =~ "--brew" ]]; then
	echo "\n👷 Running brew configuration script 🚧\n"

	zsh ./scripts/brew.sh
fi

#
# Zsh
#

if [[ "$arg_array" =~ "--zsh" ]]; then
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
# Git
#

if [[ "$arg_array" =~ "--git" ]]; then
	echo "\n👷 Running git configuration script 🚧\n"
	try ln -sr ./git ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# neovim
#

if [[ "$arg_array" =~ "--nvim" ]]; then
	echo "\n👷 Running neovim configuration script 🚧\n"
	try git clone --recursive https://github.com/ladislas/nvim ~/.config/nvim
fi

#
# data
#

if [[ "$arg_array" =~ "--data" ]]; then
	echo "\n👷 Running XGD Data configuration script 🚧\n"
	try mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}
	try ln -sr ./data/* ${XDG_DATA_HOME:-$HOME/.local/share}
fi

#
# dev directory structure
#

if [[ "$arg_array" =~ "--dev" ]]; then
	echo "\n👷 Running dev directory structure configuration script 🚧\n"
	try mkdir -p $HOME/dev/{ladislas,leka,osx-cross,tmp}
fi

#
# Install gems and pip packages
#

if [[ "$arg_array" =~ "--gem-pip" ]]; then
	echo "\n👷 Installing useful gems, pip & node packages 🚧\n"
	try gem install --no-document cocoapods fastlane neovim
	try pip install -U --user mbed-cli pyserial neovim
	try npm install -g neovim
fi
