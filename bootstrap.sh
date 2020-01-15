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
available_args=("--hello" "--macos" "--brew" "--zsh" "--git" "--symlink" "--nvim" "--dev" "--data")

#
# Check if arguments have been passed
#

if [ ${#arg_array[@]} -eq 0 ]; then
	echo "⚠️  No arguments have been passed."
	echo "Please try again with one of those: $available_args"
	return 1
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

if [[ "$@" =~ "--macos" || "$@" =~ "--brew" ]]; then
	if ! sudo -n true 2>/dev/null; then
		echo "⚠️  Please enter your password as some scripts require sudo access."
		sudo -v
	fi
fi

#
# Hello, World! -- test argument
#

if [[ "$@" =~ "--hello" ]]; then
	try echo "Hello, World!"
	try ls -al $HOME
	try ls -al $HOME/null
fi

#
# macOS
#

if [[ "$@" =~ "--macos" ]]; then
	echo "Running macOS configuration script"

	# Set macOS defaults
	zsh ./scripts/macos.sh
fi

#
# Brew
#

if [[ "$@" =~ "--brew" ]]; then
	echo "Running brew configuration script"

	zsh ./scripts/brew.sh
fi

#
# Zsh
#

if [[ "$@" =~ "--zsh" ]]; then
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

	try ln -sf $PWD/symlink/.zshenv $HOME/.zshenv
	try mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}
	try ln -sf $PWD/zsh ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# Git
#

if [[ "$@" =~ "--git" ]]; then
	echo "Running git configuration script"
	ln -s $PWD/git ${XDG_CONFIG_HOME:-$HOME/.config}/
fi

#
# neovim
#

if [[ "$@" =~ "--nvim" ]]; then
	echo "Running neovim configuration"
	git clone --recursive https://github.com/ladislas/nvim ~/.config/nvim
fi

#
# data
#

if [[ "$@" =~ "--data" ]]; then
	echo "Running XGD Data configuration"
	try mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}
	try ln -sr ./data/* ${XDG_DATA_HOME:-$HOME/.local/share}
fi
