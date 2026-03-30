#!/usr/bin/env zsh

#
# Export env variables & global settings
#
# Authors:
#	 Ladislas de Toldi <ladislas at detoldi dot me>
#

#
# Config exports
#

export ZFUNCTIONSDIR=$ZDOTDIR/functions
export ZMODULESDIR=$ZDOTDIR/modules
export ZCOMPLETIONSDIR=$ZDOTDIR/completions

#
# Language
#

export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export LC_COLLATE='C' # Show dotfiles first with ls -al

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
	export BROWSER='open'
fi

#
# Homebrew
#

if test -d "/opt/homebrew/bin"; then
	export BREW_PREFIX="/opt/homebrew"
elif test -d "/usr/local/bin"; then
	export BREW_PREFIX="/usr/local"
fi

#
# Manpage
#

export PAGER='less'
# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X'
# Highlight section titles in manual pages.
export LESS_TERMCAP_md="${yellow}"
# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
cdpath=(
	dev
	$cdpath
)

# Set the list of directories that Zsh searches for programs.
path=(
	$BREW_PREFIX/{bin,sbin}
	$path
)

#
# Misc
#

# zsh-syntax-highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$BREW_PREFIX/share/zsh-syntax-highlighting/highlighters"
