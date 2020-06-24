#!/usr/bin/env zsh

#
# Helpers
#

# create tmp file & schedule delete if error
typeset -x tmp_file=$(mktemp)
trap "rm -f $tmp_file" 0 2 3 15

typeset -Ux failed_commands=()

function list_failed_commands {
	ret=0
	echo ""
	if [ ${#failed_commands[@]} -eq 0 ]; then
		echo "🎉 The bootstrap process completed successfully! 💪"
	else
		echo "💥 The following commands have failed: 💥"
		for cmd in $failed_commands; do
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
