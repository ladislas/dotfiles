#!/usr/bin/env zsh

# Continue on error
set +e

source "$DOTFILES_DIR/scripts/desktop_state.sh"
source "$DOTFILES_DIR/scripts/dock.sh"

user_library_path="$HOME/Library"
dotf_library_path="$DOTFILES_DIR/Library"
rsync_backup_path="$DOTFILES_DIR/Library/_backup"

typeset -a installed_managed_apps
typeset -a bootstrap_managed_apps

for app in "${managed_desktop_bootstrap_apps[@]}"; do
	if managed_desktop_has_app "$app"; then
		installed_managed_apps+=("$app")
		if managed_desktop_bootstrap_root_missing "$app" "$user_library_path"; then
			bootstrap_managed_apps+=("$app")
		fi
	fi
done

if (( ${#bootstrap_managed_apps[@]} > 0 )); then
	print_action "Bootstrap launch managed applications when needed"
	for app in "${bootstrap_managed_apps[@]}"; do
		try_can_fail open -a "$app"
	done

	echo ""
	echo "› Wait for managed apps to launch"
	try sleep 10

	echo ""
	echo "› Make sure the managed apps have launched and that you've accepted any system dialog before moving forward"
	echo ""
	printf "👀 Are you ready to continue? (y/n) "
	if ! is_ci ; then
		read
		if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
			echo ""
			echo "Goodbye, come again!..."
			exit 0
		fi
	fi
fi

if (( ${#installed_managed_apps[@]} > 0 )); then
	print_action "Quit managed applications before copying preferences"
	for app in "${installed_managed_apps[@]}"; do
		managed_desktop_quit_app "$app"
	done

	echo ""
	echo "› Wait for managed apps to quit"
	try sleep 10
fi

print_action "Sync managed desktop state to $user_library_path"
managed_desktop_sync_roots "$dotf_library_path" "$user_library_path" "$rsync_backup_path"

apply_dock_manifest

print_action "Kill Dock for changes to take effect"
try_can_fail killall Dock
