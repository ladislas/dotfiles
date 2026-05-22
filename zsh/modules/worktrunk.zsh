#!/usr/bin/env zsh

# Worktrunk shell integration.
# Must load after compinit so Worktrunk can register completions.
if command -v wt >/dev/null 2>&1; then
	eval "$(command wt config shell init zsh)"
fi
