#!/usr/bin/env zsh

typeset -ga managed_desktop_file_roots
managed_desktop_file_roots=(
	"Preferences/com.apple.dt.Xcode.plist"
	"Preferences/com.apple.symbolichotkeys.plist"
	"Preferences/com.googlecode.iterm2.plist"
	"Preferences/com.knollsoft.Rectangle.plist"
	"Preferences/com.uranusjr.macdown.plist"
	"Preferences/net.freemacsoft.AppCleaner-SmartDelete.plist"
	"Preferences/net.freemacsoft.AppCleaner.plist"
	"Spelling/LocalDictionary"
)

typeset -ga managed_desktop_directory_roots
managed_desktop_directory_roots=(
	"Colors"
	"Developer/Xcode/UserData"
	"Services"
)

typeset -ga managed_desktop_bootstrap_apps
managed_desktop_bootstrap_apps=(
	"AppCleaner"
	"iTerm"
	"MacDown"
	"Rectangle"
	"Xcode"
)

function managed_desktop_has_app {
	local app="$1"
	local app_path

	app_path="$(mdfind "kMDItemContentType == 'com.apple.application-bundle' && kMDItemFSName == '$app.app'" | head -n 1)"
	[ -n "$app_path" ] || [ -d "/Applications/$app.app" ] || [ -d "/System/Applications/$app.app" ]
}

function managed_desktop_bootstrap_root_missing {
	local app="$1"
	local user_library_path="${2:-$HOME/Library}"

	case "$app" in
		"AppCleaner")
			[ ! -e "$user_library_path/Preferences/net.freemacsoft.AppCleaner.plist" ]
			;;
		"iTerm")
			[ ! -e "$user_library_path/Preferences/com.googlecode.iterm2.plist" ]
			;;
		"MacDown")
			[ ! -e "$user_library_path/Preferences/com.uranusjr.macdown.plist" ]
			;;
		"Rectangle")
			[ ! -e "$user_library_path/Preferences/com.knollsoft.Rectangle.plist" ]
			;;
		"Xcode")
			[ ! -e "$user_library_path/Preferences/com.apple.dt.Xcode.plist" ] || [ ! -d "$user_library_path/Developer/Xcode/UserData" ]
			;;
		*)
			return 1
			;;
	esac
}

function managed_desktop_quit_app {
	local app="$1"

	if [[ "$app" == "iTerm" ]]; then
		try_can_fail osascript -e 'if application id "com.googlecode.iterm2" is running then tell application id "com.googlecode.iterm2" to quit'
		return
	fi

	try_can_fail osascript -e "if application \"$app\" is running then tell application \"$app\" to quit"
}

function managed_desktop_sync_file_root {
	local source_library_path="$1"
	local destination_library_path="$2"
	local root="$3"
	local backup_root="$4"
	local source_path="$source_library_path/$root"
	local destination_path="$destination_library_path/$root"
	local backup_dir="$backup_root/$(dirname -- "$root")"

	try mkdir -p "$(dirname -- "$destination_path")"
	try mkdir -p "$backup_dir"

	if [ -e "$source_path" ]; then
		try rsync -a --backup --backup-dir="$backup_dir" "$source_path" "$destination_path"
	elif [ -e "$destination_path" ]; then
		try rm -rf "$destination_path"
	fi
}

function managed_desktop_directory_excludes_for_root {
	local root="$1"

	case "$root" in
		"Developer/Xcode/UserData")
			print -l -- \
				"Capabilities/" \
				"CoverageReport.xcstate" \
				"FontAndColorThemes/Default (Dark).xccolortheme" \
				"FontAndColorThemes/Default (Light).xccolortheme" \
				"IB Support/" \
				"IB%20Support/" \
				"IDEDocumentationWindow.xcuserstate" \
				"IDEEditorInteractivityHistory" \
				"IDEPreferencesController.xcuserstate" \
				"Previews/" \
				"Provisioning Profiles/" \
				"TestReportState.xcstate" \
				"XcodeCloud/"
			;;
		esac
}

function managed_desktop_sync_directory_root {
	local source_library_path="$1"
	local destination_library_path="$2"
	local root="$3"
	local backup_root="$4"
	local source_path="$source_library_path/$root"
	local destination_path="$destination_library_path/$root"
	local backup_dir="$backup_root/$root"
	local exclude_pattern
	local -a rsync_args

	rsync_args=(
		-a
		--delete
		--backup
		"--backup-dir=$backup_dir"
		--exclude '.DS_Store'
		--exclude '._*'
	)

	if [[ "$MANAGED_DESKTOP_DELETE_EXCLUDED" == true ]]; then
		rsync_args+=(--delete-excluded)
	fi

	for exclude_pattern in "${(@f)$(managed_desktop_directory_excludes_for_root "$root")}"; do
		[ -n "$exclude_pattern" ] || continue
		rsync_args+=(--exclude "$exclude_pattern")
	done

	try mkdir -p "$(dirname -- "$destination_path")"
	try mkdir -p "$backup_dir"

	if [ -d "$source_path" ]; then
		try mkdir -p "$destination_path"
		try rsync "${rsync_args[@]}" "$source_path/" "$destination_path/"
	elif [ -e "$destination_path" ]; then
		try rm -rf "$destination_path"
	fi
}

function managed_desktop_sync_roots {
	local source_library_path="$1"
	local destination_library_path="$2"
	local backup_root="$3"
	local root

	for root in "${managed_desktop_file_roots[@]}"; do
		print_action "Sync $root"
		managed_desktop_sync_file_root "$source_library_path" "$destination_library_path" "$root" "$backup_root"
	done

	for root in "${managed_desktop_directory_roots[@]}"; do
		print_action "Sync $root"
		managed_desktop_sync_directory_root "$source_library_path" "$destination_library_path" "$root" "$backup_root"
	done
}
