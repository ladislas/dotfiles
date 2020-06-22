#!/usr/bin/env zsh

#
# Source helper functions
#

source ./scripts/helpers/include.sh
alias try='./scripts/helpers/try.sh'

#
# Set output level (verbose / super_verbose)
#

if [[ "$1" =~ "-vv" ]]; then
	alias try="try -vv"
	shift
elif [[ "$1" =~ "-v" || "$1" =~ "--verbose" ]]; then
	alias try="try -v"
	shift
fi

#
# Set arguments
#

main_commands=("--all" "--force" "--ci" "--dry-run")
ci_commands=(    "--hello"                                           "--zsh" "--git" "--symlink" "--nvim"         "--data" "--macos")
script_commands=("--hello" "--brew" "--apps-install" "--apps-config" "--zsh" "--git" "--symlink" "--nvim" "--dev" "--data" "--macos")


arg_array=($@)
available_args=( ${main_commands[*]} ${script_commands[*]} )

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
	echo "\n"
    echo "👷 Installing brew & coreutils 🚧"
    try /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install coreutils
elif [[ $(command -v gls) == "" ]]; then
	echo "\n"
	echo "👷 Installing coreutils 🚧"
	brew install coreutils
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
		echo ""
		echo "⚠️ ⚠️ ⚠️"
		echo "You are about to run all the scripts. This it NOT recommended"
		echo "unless you know what you are doing!"
		echo "Please confirm that you have read the source files and are okay with that."
		echo "Unexepected behaviors can occur!"
		echo "⚠️ ⚠️ ⚠️"
		echo ""
		read "Are you sure you want to continue? (y/n)"
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
			[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
		fi
	fi

	if [[ $arg_array =~ "--ci" ]]; then
		typeset -x CI_TEST=1
	fi

	echo ""
	echo "⚠️ Running bootstrap with all args!"
	arg_array=($script_commands)
fi

#
# Arg: --ci
#

if [[ $arg_array =~ "--ci" ]]; then
	echo ""
	echo "⚠️ Running bootstrap for testing with the following args:"
	echo "\t$ci_commands"
	arg_array=($ci_commands)
	typeset -x CI_TEST=1
fi

#
# Arg: --dry-run
#

if [[ $arg_array =~ "--dry-run" ]]; then
	echo ""
	echo "⚠️ Running bootstrap as dry run. Nothing will be installed..."
	echo "\t$ci_commands"
	arg_array=($ci_commands)
	typeset -x CI_TEST=1
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
	echo "\n"
	echo "👷 Starting Hello, World! script 🚧\n"
	echo "Hello, World!"
fi

#
# Arg: --brew
#

if [[ $arg_array =~ "--brew" ]]; then
	echo "\n"
	echo "👷 Starting brew configuration script 🚧\n"
	source ./scripts/brew.sh
fi

#
# Arg: --apps-install
#

if [[ $arg_array =~ "--apps-install" ]]; then
	echo "\n"
	echo "👷 Starting applications installation script 🚧\n"
	source ./scripts/apps.sh
fi

#
# Arg: --apps-config
#

if [[ $arg_array =~ "--apps-config" ]]; then
	echo "\n"
	echo "👷 Starting applications configuration script 🚧\n"
	source ./scripts/apps_config.sh
fi

#
# Arg: --macos
#

if [[ $arg_array =~ "--macos" ]]; then
	echo "\n"
	echo "👷 Starting macOS configuration script 🚧\n"
	source ./scripts/macos.sh
fi

#
# Arg: --zsh
#

if [[ $arg_array =~ "--zsh" ]]; then
	echo "\n"
	echo "👷 Starting zsh configuration script 🚧\n"

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

	try chmod go-w "/usr/local/share"

	try ln -sr ./symlink/.zshenv $HOME/.zshenv
	try mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}
	try ln -sr ./zsh ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Arg: --git
#

if [[ $arg_array =~ "--git" ]]; then
	echo "\n"
	echo "👷 Starting git configuration script 🚧\n"
	try ln -sr ./git ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Arg: --neovim
#

if [[ $arg_array =~ "--nvim" ]]; then
	echo "\n"
	echo "👷 Starting neovim configuration script 🚧\n"
	try git clone --recursive https://github.com/ladislas/nvim ~/.config/nvim
fi

#
# Arg: --data
#

if [[ $arg_array =~ "--data" ]]; then
	echo "\n"
	echo "👷 Starting XGD Data configuration script 🚧\n"
	try mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}
	try ln -sr ./data/* ${XDG_DATA_HOME:-$HOME/.local/share}
fi

#
# Arg: --dev
#

if [[ $arg_array =~ "--dev" ]]; then
	if [[ ! -n $CI_TEST ]]; then
		echo "\n"
		echo "👷 Starting personnal dev configuration script 🚧\n"
		echo ""
		echo "⚠️ To run the script, git must be configured and you will need your Github password."
		echo ""
		read "Are you sure you want to continue? (y/n)"
		if [[ ! $REPLY =~ ^[Yy]$ ]]
		then
			[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
		fi
	fi

	source ./scripts/dev.sh
fi

#
# List failed commands & delete tmp_file
#

list_failed_commands
rm -rf $tmp_file
