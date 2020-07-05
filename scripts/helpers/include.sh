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

function print_action {
	echo ""
	echo "› $@"
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

function ask_for_sudo {
	echo "Please enter your password."
	sudo -v
	if [ ! $? -eq 0 ]; then
		echo ""
		echo "Goodbye, come again!..."
		exit 0
	fi
}
