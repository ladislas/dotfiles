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
# Functions
#

# Load helper functions
. $ZFUNCTIONSDIR/helper.zsh

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
	export BROWSER='open'
fi

#
# Editors
#

if which nvim >/dev/null 2>&1; then
	export EDITOR="nvim"
	export VISUAL='nvim'
else
	export EDITOR="vim"
	export VISUAL='vim'
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
	/usr/local/{bin,sbin}
	$path
)

#
# Misc
#

# Avoid issues with `gpg` as installed via Homebrew.
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty);

# zsh-syntax-highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters
