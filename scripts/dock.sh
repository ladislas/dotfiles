#!/usr/bin/env zsh

typeset -gr dock_manifest_path="$DOTFILES_DIR/config/dock.tsv"

function dock_manifest_expand_path {
	local path="$1"

	if [[ "$path" == "~/"* ]]; then
		print -r -- "$HOME/${path#\~/}"
		return
	fi

	print -r -- "$path"
}

function dock_folder_sort_name {
	case "$1" in
		1)
			print -r -- "name"
			;;
		2)
			print -r -- "dateadded"
			;;
		3)
			print -r -- "datemodified"
			;;
		4)
			print -r -- "datecreated"
			;;
		5)
			print -r -- "kind"
			;;
		*)
			print -r -- "name"
			;;
	esac
}

function dock_folder_display_name {
	case "$1" in
		0)
			print -r -- "stack"
			;;
		*)
			print -r -- "folder"
			;;
	esac
}

function dock_folder_view_name {
	case "$1" in
		1)
			print -r -- "fan"
			;;
		2)
			print -r -- "grid"
			;;
		3)
			print -r -- "list"
			;;
		*)
			print -r -- "auto"
			;;
	esac
}

function export_dock_manifest {
	print_action "Export Dock manifest to $dock_manifest_path"
	try mkdir -p "$(dirname -- "$dock_manifest_path")"
	try /usr/bin/python3 "$DOTFILES_DIR/scripts/export_dock_manifest.py" "$HOME/Library/Preferences/com.apple.dock.plist" "$dock_manifest_path"
}

function apply_dock_manifest {
	local section
	local type
	local condition
	local item_path
	local arrangement
	local displayas
	local showas
	local expanded_path

	print_action "Apply Dock manifest from $dock_manifest_path"

	if ! command -v dockutil > /dev/null 2>&1; then
		print_error "dockutil not found — run bootstrap with --brew first"
		return 1
	fi

	if [[ ! -f "$dock_manifest_path" ]]; then
		print_error "Dock manifest not found: $dock_manifest_path"
		return 1
	fi

	try dockutil --no-restart --remove all

	while IFS=$'\t' read -r section type condition item_path arrangement displayas showas; do
		[ -n "$section" ] || continue
		[[ "$section" == "section" ]] && continue
		[[ "$section" == \#* ]] && continue

		expanded_path="$(dock_manifest_expand_path "$item_path")"

		if [[ "$section" == "apps" ]]; then
			if [[ "$condition" == "if-installed" && ! -d "$expanded_path" ]]; then
				continue
			fi

			try dockutil --no-restart --add "$expanded_path" --section apps
			continue
		fi

		if [[ "$section" == "others" ]]; then
			try dockutil --no-restart --add "$expanded_path" --section others --display "$(dock_folder_display_name "$displayas")" --view "$(dock_folder_view_name "$showas")" --sort "$(dock_folder_sort_name "$arrangement")"
		fi
	done < "$dock_manifest_path"
}
