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
	cmd="$@"
	echo ""
	echo "Running \"$cmd\" ..."
	$@
	if [ $? -eq 0 ]; then
		echo "Running \"$cmd\" ... ✅"
	else
		echo "Running \"$cmd\" ... ❌"
	fi
}

#
# Arguments
#

arg_array=($@)
main_commands=("--all" "--force" "--test")
script_commands=("--hello" "--macos" "--brew" "--zsh" "--git" "--symlink" "--nvim" "--dev" "--data" "--gem-pip")
available_args=( ${main_commands[*]} ${script_commands[*]} )
test_commands=("--hello" "--macos"  "--zsh" "--git" "--symlink" "--nvim" "--dev" "--data" "--gem-pip")

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
	echo ""
	if [[ ! "$arg_array" =~ "--force" ]]; then
		echo "⚠️  You are about to run all the scripts. Please confirm that you have read\nthe source files and are okay with that. Unexepected behaviors can occur!"
		read "?Are you sure you want to continue? "
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
			[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
		fi
	fi

	echo "⚠️  Running all install scripts!"
	arg_array=($script_commands)
fi


#
# Test scripts
#

if [[ "$arg_array" =~ "--test" ]]; then
	echo "⚠️  Running all scripts except --brew for testing!"
	arg_array=($test_commands)
fi

#
# Check if all arguments exist, if not exit
#

for arg in $arg_array; do
	if [[ ! " ${available_args[@]} " =~ " ${arg} " ]]; then
		echo "⚠️  Unrecognized argument: $arg"
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
	echo "Running macOS configuration script"

	# Set macOS defaults
	zsh ./scripts/macos.sh
fi

#
# Brew
#

if [[ "$arg_array" =~ "--brew" ]]; then
	echo "Running brew configuration script"

	zsh ./scripts/brew.sh
fi

#
# Zsh
#

if [[ "$arg_array" =~ "--zsh" ]]; then
	echo "Running zsh configuration script"

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
	echo "Running git configuration script"
	ln -sr ./git ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# neovim
#

if [[ "$arg_array" =~ "--nvim" ]]; then
	echo "Running neovim configuration"
	git clone --recursive https://github.com/ladislas/nvim ~/.config/nvim
fi

#
# data
#

if [[ "$arg_array" =~ "--data" ]]; then
	echo "Running XGD Data configuration"
	try mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}
	try ln -sr ./data/* ${XDG_DATA_HOME:-$HOME/.local/share}
fi

#
# dev directory structure
#

if [[ "$arg_array" =~ "--dev" ]]; then
	echo "Running dev directory structure configuration"
	try mkdir -p $HOME/dev/{ladislas,leka,osx-cross,tmp}
fi

#
# Install gems and pip packages
#

if [[ "$arg_array" =~ "--gem-pip" ]]; then
	echo "Install useful gems and pip packages"
	try gem install --no-document cocoapods fastlane neovim
	try pip install -U --user mbed-cli pyserial neovim
	try npm install -g neovim
fi
