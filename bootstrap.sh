#!/usr/bin/env zsh

#
# Source helper functions
#

trap "exit 1" INT

typeset -x  DOTFILES_DIR=$(pwd)
typeset -Ux FAILED_COMMANDS=()
typeset -Ux CAN_FAIL_COMMANDS=()
typeset -x  ARG_ARRAY=()

# create tmp file & schedule delete if error
typeset -x TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" 0 2 3 15

source $DOTFILES_DIR/scripts/helpers/include.sh

function try {
	. $DOTFILES_DIR'/scripts/helpers/try.sh' $@
}

alias try_can_fail="try -x"

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

qualifier_commands=( "-v" "-vv" "--verbose" "--force" )
     main_commands=( "--all"  "--ci" "--dry-run" )
	   ci_commands=( "--hello" "--zsh" "--git" "--nvim" "--data" "--macos" "--brew" "--apps-install" "--apps-config"                                     )
   script_commands=( "--hello" "--zsh" "--git" "--nvim" "--data" "--macos" "--brew" "--apps-install" "--apps-config" "--dev" "--rsync" "--computer_name=" )


ARG_ARRAY=($@)
available_args=( ${qualifier_commands[*]} ${main_commands[*]} ${script_commands[*]} )

#
# Check that arguments have been passed, if not exit
#

if array_is_empty $ARG_ARRAY ; then
	echo "💥 No arguments have been passed."
	echo "Please try again with one of those: $available_args"
	exit 1
fi

#
# Get computer name if provided
#

if [[ $ARG_ARRAY =~ "--computer_name=" ]]; then
	COMPUTER_NAME=$(echo $ARG_ARRAY | ggrep -oP '(?<=--computer_name=)[^ ]+')
	ARG_ARRAY=(${(@)ARG_ARRAY:#--computer_name=*})
fi

#
# Check that passed arguments are available, if not exit
#

for arg in $ARG_ARRAY; do
	if [[ ! " ${available_args[@]} " =~ " ${arg} " ]]; then
		echo "💥 Unrecognized argument: $arg"
		echo "Please try again with one of those: $available_args"
		exit 1
	fi
done

#
# Arg: --dry-run
#

if is_dry_run ; then
	echo ""
	echo "🏃 Running bootstrap as dry run. Nothing will be installed or modified... 🛡️"
	typeset -x DRY_RUN=true
fi

#
# Check for brew & coreutils, if not install
#

if ! is_dry_run ; then
	print_section "Checking for brew & coreutils"
	if [[ $(command -v brew) == "" ]]; then
		print_action "Install brew"
		fake_try "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\""
	    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
	fi
	if [[ $(command -v gls) == "" ]]; then
		print_action "Install coreutils"
		fake_try "brew install coreutils"
		brew install coreutils
	fi
	if [ ! $? -eq 0 ]; then
		echo "💥 Could not install brew & coreutils, exiting with status code $?"
		exit 1
	fi
fi

if test -d "/opt/homebrew/bin"; then
	export BREW_PREFIX="/opt/homebrew"
elif test -d "/usr/local/bin"; then
	export BREW_PREFIX="/usr/local"
fi

print_action "Add gnubin to path"
fake_try "export PATH=\"$BREW_PREFIX/opt/coreutils/libexec/gnubin:\$PATH\""
export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"

#
# Arg: --all
#

if args_contain "--all" ; then
	if ! args_contain "--force" ; then
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

	echo ""
	echo "⚠️   Running bootstrap with all args! ⚠️"
	echo "\t$script_commands"
	ARG_ARRAY=($script_commands)
fi

#
# Arg: --ci
#

if args_contain "--ci" ; then
	echo ""
	echo "🔬 Running bootstrap for testing with the following args: 🧪"
	echo "\t$ci_commands"
	ARG_ARRAY=($ci_commands)
fi

#
# Sudo power
#

if args_contain "--macos" || args_contain "--brew" ; then
	if ! sudo -n true 2>/dev/null; then
		echo ""
		echo "🔐 Args --macos & --brew require sudo to run. 🔐"
		ask_for_sudo
	fi
fi

#
# Arg: --hello
#

if args_contain "--hello" ; then
	print_section "Starting Hello, World! script"
	print_action "Make sure we're good to go"
	try echo "Hello, World!"
	# try sleep 3
	try echo "Let's get moving!"
	try_can_fail false
fi

#
# Arg: --brew
#

if args_contain "--brew" ; then
	print_section "Starting brew configuration script"
	source $DOTFILES_DIR/scripts/brew.sh
fi

#
# Arg: --apps-install
#

if args_contain "--apps-install" ; then
	print_section "Starting applications installation script"
	source $DOTFILES_DIR/scripts/apps.sh
fi

#
# Arg: --apps-config
#

if args_contain "--apps-config" ; then
	print_section "Starting applications configuration script"
	source $DOTFILES_DIR/scripts/apps_config.sh
fi

#
# Arg: --zsh
#

if args_contain "--zsh" ; then
	print_section "Starting zsh configuration script"

	ask_for_sudo

	# Switch to using brew-installed zsh as default shell
	if ! fgrep -q "${BREW_PREFIX}/bin/zsh" /etc/shells ; then
		print_action "Setting brew zsh as default shell"
		try echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells;
		try chsh -s "${BREW_PREFIX}/bin/zsh";
	fi;

	print_action "Clean up zcompdump"
	try rm -f ~/.zcompdump
	try rm -f $DOTFILES_DIR/zsh/.zcompdump
	try rm -f $DOTFILES_DIR/zsh/.zcompdump.zwc

	print_action "chmod $BREW_PREFIX/share for completion"
	try chmod -R go-w "$BREW_PREFIX/share"

	print_action "Symlink config files"
	try mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}
	try ln -sr $DOTFILES_DIR/symlink/.zshenv $HOME/.zshenv
	try ln -sr $DOTFILES_DIR/zsh ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Arg: --git
#

if args_contain "--git" ; then
	print_section "Starting git configuration script"
	print_action "Symlink config files"
	try mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}
	try ln -sr $DOTFILES_DIR/git ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Arg: --neovim
#

if args_contain "--nvim" ; then
	print_section "Starting neovim configuration script"
	print_action "Git clone neovim config"
	try git clone --recursive https://github.com/ladislas/nvim ~/.config/nvim
fi

#
# Arg: --data
#

if args_contain "--data" ; then
	print_section "Starting XDG Data configuration script"
	print_action "Symlink config files"
	try mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}
	try ln -sr $DOTFILES_DIR/data/* ${XDG_DATA_HOME:-$HOME/.local/share}
fi

#
# Arg: --dev
#

if args_contain "--dev" ; then
	print_section "Starting personnal dev configuration script"
	source $DOTFILES_DIR/scripts/dev.sh
fi

#
# Arg: --macos
#

if args_contain "--macos" ; then
	print_section "Starting macOS configuration script"
	# abort if COMPUTER_NAME is not set
	if [[ -z $COMPUTER_NAME ]]; then
		echo "💥 --macos requires a computer name to be set with --computer_name=YOUR_NAME"
		exit 1
	fi
	source $DOTFILES_DIR/scripts/macos.sh
fi

#
# Arg: --rsync
#

if args_contain "--rsync" ; then
	print_section "Starting rsync configuration script"
	source $DOTFILES_DIR/scripts/rsync_config.sh
fi

#
# List failed commands & delete TEMP_FILE
#

list_failed_commands
rm -rf $TEMP_FILE
