# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal macOS dotfiles repository with zsh configuration, git customization, and automated system setup. Uses XDG Base Directory Specification to keep `$HOME` clean.

## Bootstrap Commands

```bash
# Run the bootstrap process
zsh bootstrap.sh [arguments]

# Available arguments:
# --hello          - Basic sanity check
# --zsh            - Setup zsh as default shell, symlink configs
# --git            - Symlink git configuration
# --nvim           - Clone neovim config repository
# --data           - Symlink XDG data files
# --brew           - Install Homebrew formulae
# --apps-install   - Install application casks
# --apps-config    - Sync application preferences
# --macos          - Configure macOS system preferences (requires --computer_name=xxx)
# --dev            - Setup development directory structure

# Modifiers:
# --all            - Run all scripts
# --force          - Skip confirmations
# --ci             - CI mode
# -v / -vv         - Verbose output
# --dry-run        - Preview without changes
```

## Architecture

### Directory Structure

- `bootstrap.sh` - Main entry point, orchestrates all setup
- `scripts/` - Individual setup scripts (brew.sh, apps.sh, macos.sh, etc.)
- `scripts/helpers/` - Shared utilities (include.sh, try.sh)
- `zsh/` - ZSH configuration (symlinked to ~/.config/zsh)
- `git/` - Git configuration (symlinked to ~/.config/git)
- `symlink/` - Files symlinked directly to $HOME
- `Library/` - macOS application preferences and configs
- `config/` - Application-specific configurations
- `data/` - XDG data files (symlinked to ~/.local/share)

### XDG Configuration Flow

```
$HOME/.zshenv (symlink) → dotfiles/symlink/.zshenv
    ↓ sets ZDOTDIR
$HOME/.config/zsh → dotfiles/zsh/
    ↓ loads
.zshenv → .zshrc → modules/*.zsh
```

### ZSH Module System

Modular configuration in `zsh/modules/`:
- `completion.zsh` - Advanced completion with fuzzy matching
- `editor.zsh` - VI/Emacs keybindings
- `directory.zsh` - Directory navigation (AUTO_CD, pushd/popd)
- `history.zsh` - Shared history with deduplication
- `prompt.zsh` - Custom prompt with git info
- `autosuggestions.zsh` - zsh-autosuggestions plugin
- `history-substring-search.zsh` - History substring search

Custom functions in `zsh/functions/`:
- `git-info.zsh` - Git status for prompt
- `git-dir.zsh` - Current git directory
- `helper.zsh` - Utility functions (is-callable, profile, coalesce)

### Bootstrap Error Handling

The `try` function in `scripts/helpers/try.sh` wraps commands with:
- Execution tracking
- Timing information
- Error collection (reported at end of run)

Use `try_can_fail` for non-critical operations.

## Git Configuration

Git config in `git/config` includes 50+ aliases. Key ones:
- `mnoff` - Merge with no-ff and emoji prefix
- `mmnoff` - Complex PR merge workflow (rebase, force-with-lease)
- `rebdef` - Rebase on default branch
- `gl/gll` - Pretty log formats
- `prc` - PR checkout via GitHub CLI
- `fc/fm` - Find commits by code/message

## CI

GitHub Actions workflow in `.github/workflows/CI.yml` runs `zsh bootstrap.sh --ci` which executes: `--hello --zsh --git --brew`.
