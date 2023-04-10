#!/usr/bin/env zsh

#
# Integrates zsh-autosuggestions into Prezto.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Load dependencies.
# pmodload 'editor'

# Source module files.
if [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] ; then
	source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

#
# Highlighting
#

# Set highlight color, default 'fg=8'.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

#
# Key Bindings
#

if [[ -n "$key_info" ]]; then
  # vi
  bindkey -M viins "$key_info[Control]F" vi-forward-word
  bindkey -M viins "$key_info[Control]E" vi-add-eol
fi
