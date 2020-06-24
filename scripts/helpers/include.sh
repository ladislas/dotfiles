#!/usr/bin/env zsh

#
# Helpers
#

function list_failed_commands {
	ret=0
	echo ""
	if [ ${#FAILED_COMMANDS[@]} -eq 0 ]; then
		echo "🎉 The bootstrap process completed successfully! 💪"
	else
		echo "💥 The following commands have failed: 💥"
		for cmd in $FAILED_COMMANDS; do
			echo "\t- $cmd"
		done
		exit 1
	fi

	echo ""
	echo "💡 Note that some of these changes require a logout/restart 💻 to take effect 🚀"

	exit $ret
}

function print_section {
	echo "\n"
	echo "👷 $@ 🚧"
}

function is_dry_run {
	if [[ $ARG_ARRAY =~ "--dry-run" ]]; then
		return 0
	else
		return 1
	fi
}

function args_contain {
	if [[ $ARG_ARRAY =~ $@ ]]; then
		return 0
	else
		return 1
	fi
}
