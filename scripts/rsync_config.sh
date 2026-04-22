#!/usr/bin/env zsh

# Continue on error
set +e

source "$DOTFILES_DIR/scripts/desktop_state.sh"

user_library_path="$HOME/Library"
dotf_library_path="$DOTFILES_DIR/Library"
rsync_backup_path="$DOTFILES_DIR/Library/_backup"

export MANAGED_DESKTOP_DELETE_EXCLUDED=true

print_action "Export managed desktop state to $dotf_library_path"
managed_desktop_sync_roots "$user_library_path" "$dotf_library_path" "$rsync_backup_path"
