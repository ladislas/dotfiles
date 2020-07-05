#!/usr/bin/env zsh

#
# Source helper functions
#

trap "exit 1" INT

typeset -x DOTFILES_DIR=$(pwd)
typeset -Ux FAILED_COMMANDS=()
typeset -x ARG_ARRAY=()

# create tmp file & schedule delete if error
typeset -x TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" 0 2 3 15

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
	ci_commands=( "--hello" "--zsh" "--git" "--symlink" "--nvim" "--data" "--macos" "--brew" "--apps-install" "--apps-config"        )
script_commands=( "--hello" "--zsh" "--git" "--symlink" "--nvim" "--data" "--macos" "--brew" "--apps-install" "--apps-config" "--dev")


ARG_ARRAY=($@)
available_args=( ${main_commands[*]} ${script_commands[*]} )

#
# Check that arguments have been passed, if not exit
#

if array_is_empty $ARG_ARRAY ; then
	echo "💥 No arguments have been passed."
	echo "Please try again with one of those: $available_args"
	exit 1
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
	    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	    print_action "Install coreutils"
	    brew install coreutils
	elif [[ $(command -v gls) == "" ]]; then
		print_action "Install coreutils"
		brew install coreutils
	fi
	if [ ! $? -eq 0 ]; then
		echo "💥 Could not install brew & coreutils, exiting with status code $?"
		exit 1
	fi
fi

export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

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

	if is_ci ; then
		typeset -x CI_TEST=true
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
	typeset -x CI_TEST=true
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
	try sleep 3
	try echo "Let's get moving!"
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

	print_action "chmod /usr/local/share for completion"
	try chmod go-w "/usr/local/share"

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
	source $DOTFILES_DIR/scripts/macos.sh
fi

#
# List failed commands & delete TEMP_FILE
#

list_failed_commands
rm -rf $TEMP_FILE
