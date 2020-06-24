#!/usr/bin/env zsh

#
# Source helper functions
#

typeset -x DOTFILES_DIR=$(pwd)

source $DOTFILES_DIR/scripts/helpers/include.sh

function try {
	. $DOTFILES_DIR'/scripts/helpers/try.sh' $@
}


#
# Set output level (verbose / super verbose)
#

if [[ "$@" =~ "-vv" ]]; then
	alias try="try -vv"
elif [[ "$@" =~ "-v" || "$@" =~ "--verbose" ]]; then
	alias try="try -v"
fi

#
# Set arguments
#

  main_commands=( "-v" "-vv" "--verbose" "--all" "--force" "--ci" "--dry-run")
	ci_commands=( "--hello" "--zsh" "--git" "--symlink" "--nvim" "--data" "--macos"          "--apps-install" "--apps-config"        )
script_commands=( "--hello" "--zsh" "--git" "--symlink" "--nvim" "--data" "--macos" "--brew" "--apps-install" "--apps-config" "--dev")


arg_array=($@)
available_args=( ${main_commands[*]} ${script_commands[*]} )

#
# Check that arguments have been passed, if not exit
#

if [ ${#arg_array[@]} -eq 0 ]; then
	echo "💥 No arguments have been passed."
	echo "Please try again with one of those: $available_args"
	exit 1
fi

#
# Check that passed arguments are available, if not exit
#

for arg in $arg_array; do
	if [[ ! " ${available_args[@]} " =~ " ${arg} " ]]; then
		echo "💥 Unrecognized argument: $arg"
		echo "Please try again with one of those: $available_args"
		exit 1
	fi
done

#
# Arg: --dry-run
#

if [[ $arg_array =~ "--dry-run" ]]; then
	echo ""
	echo "🏃 Running bootstrap as dry run. Nothing will be installed or modified... 🛡️"
	typeset -x DRY_RUN=1
fi

#
# Check for brew & coreutils, if not install
#

if [[ $(command -v brew) == "" ]]; then
	print_section "Installing brew & coreutils"
    try /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install coreutils
elif [[ $(command -v gls) == "" ]]; then
	print_section "Installing coreutils"
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
		echo "🔥 🔥 🔥"
		echo "You are about to run all the scripts. This it NOT recommended"
		echo "unless you know what you are doing! Unexepected behaviors can occur!"
		echo "🔥 🔥 🔥"
		echo ""
		echo "Please confirm that you have read the source files and are okay with that."
		printf "👀 Are you sure you want to continue? (y/n) "
		read
		if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
			echo ""
			echo "Goodbye, come again!..."
			exit 0
		fi
	fi

	if [[ $arg_array =~ "--ci" ]]; then
		typeset -x CI_TEST=1
	fi

	echo ""
	echo "⚠️   Running bootstrap with all args! ⚠️"
	echo "\t$script_commands"
	arg_array=($script_commands)
fi

#
# Arg: --ci
#

if [[ $arg_array =~ "--ci" ]]; then
	echo ""
	echo "🔬 Running bootstrap for testing with the following args: 🧪"
	echo "\t$ci_commands"
	arg_array=($ci_commands)
	typeset -x CI_TEST=1
fi

#
# Sudo power
#

if [[ $arg_array =~ "--macos" || $arg_array =~ "--brew" ]]; then
	if ! sudo -n true 2>/dev/null; then
		echo ""
		echo "🔐 Args --macos & --brew require sudo to run. 🔐"
		echo "Please enter your password."
		sudo -v
		if [ ! $? -eq 0 ]; then
			echo ""
			echo "Goodbye, come again!..."
			exit 0
		fi
	fi
fi

#
# Arg: --hello
#

if [[ $arg_array =~ "--hello" ]]; then
	print_section "Starting Hello, World! script"
	echo ""
	echo "› Make sure we're good to go"
	try echo "Hello, World!"
	try sleep 3
	try echo "Let's get moving!"
fi

#
# Arg: --brew
#

if [[ $arg_array =~ "--brew" ]]; then
	print_section "Starting brew configuration script"
	source $DOTFILES_DIR/scripts/brew.sh
fi

#
# Arg: --apps-install
#

if [[ $arg_array =~ "--apps-install" ]]; then
	print_section "Starting applications installation script"
	source $DOTFILES_DIR/scripts/apps.sh
fi

#
# Arg: --apps-config
#

if [[ $arg_array =~ "--apps-config" ]]; then
	print_section "Starting applications configuration script"
	source $DOTFILES_DIR/scripts/apps_config.sh
fi

#
# Arg: --zsh
#

if [[ $arg_array =~ "--zsh" ]]; then
	print_section "Starting zsh configuration script"

	# Switch to using brew-installed zsh as default shell
	if ! fgrep -q "${BREW_PREFIX}/bin/zsh" /etc/shells ; then
		echo ""
		echo "› Setting brew zsh as default shell"
		try echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells;
		try chsh -s "${BREW_PREFIX}/bin/zsh";
	fi;

	echo ""
	echo "› Clean up zcompdump"
	try rm -f ~/.zcompdump
	try rm -f $DOTFILES_DIR/zsh/.zcompdump
	try rm -f $DOTFILES_DIR/zsh/.zcompdump.zwc

	echo ""
	echo "› chmod /usr/local/share for completion"
	try chmod go-w "/usr/local/share"

	echo ""
	echo "› Symlink config files"
	try mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}
	try ln -sr $DOTFILES_DIR/symlink/.zshenv $HOME/.zshenv
	try ln -sr $DOTFILES_DIR/zsh ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Arg: --git
#

if [[ $arg_array =~ "--git" ]]; then
	print_section "Starting git configuration script"

	echo ""
	echo "› Symlink config files"
	try mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}
	try ln -sr $DOTFILES_DIR/git ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Arg: --neovim
#

if [[ $arg_array =~ "--nvim" ]]; then
	print_section "Starting neovim configuration script"

	echo ""
	echo "› Git clone neovim config"
	try git clone --recursive https://github.com/ladislas/nvim ~/.config/nvim
fi

#
# Arg: --data
#

if [[ $arg_array =~ "--data" ]]; then
	print_section "Starting XDG Data configuration script"

	echo ""
	echo "› Symlink config files"
	try mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}
	try ln -sr $DOTFILES_DIR/data/* ${XDG_DATA_HOME:-$HOME/.local/share}
fi

#
# Arg: --dev
#

if [[ $arg_array =~ "--dev" ]]; then
	print_section "Starting personnal dev configuration script"
	source $DOTFILES_DIR/scripts/dev.sh
fi

#
# Arg: --macos
#

if [[ $arg_array =~ "--macos" ]]; then
	print_section "Starting macOS configuration script"
	source $DOTFILES_DIR/scripts/macos.sh
fi

#
# List failed commands & delete tmp_file
#

list_failed_commands
rm -rf $tmp_file
