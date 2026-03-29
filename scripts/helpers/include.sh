#!/usr/bin/env zsh

#
# Helpers
#

function array_is_empty {
	if [ $# -eq 0 ] || { [ $# -eq 1 ] && [ -z "$1" ]; }; then
		return 0
	fi

	return 1
}

function dedupe_array {
	local array_name="$1"
	local -a unique_values=()
	local value

	for value in "${(@P)array_name}"; do
		if ! array_contains "$value" "${unique_values[@]}"; then
			unique_values+=("$value")
		fi
	done

	eval "$array_name=(\"\${unique_values[@]}\")"
}

function array_contains {
	local needle="$1"
	shift

	local value
	for value in "$@"; do
		if [ "$value" = "$needle" ]; then
			return 0
		fi
	done

	return 1
}

function print_section {
	echo "\n"
	echo "👷 $@ 🚧"
}

function print_action {
	echo ""
	echo "› $@"
}

function fake_try {
	echo "Running $@ ... ✅ (-)"
}

function is_ci {
	if [[ -n $CI ]]; then
		return 0
	else
		return 1
	fi
}

function is_dry_run {
	if [[ "$DRY_RUN" == true ]]; then
		return 0
	else
		return 1
	fi
}

function args_contain {
	array_contains "$1" "${ARG_ARRAY[@]}"
}

function in_sandbox {
	if [ -n "$BOOTSTRAP_HOME" ]; then
		return 0
	fi

	return 1
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

function list_failed_commands {
	ret=0
	echo ""
	if array_is_empty "${FAILED_COMMANDS[@]}" && array_is_empty "${CAN_FAIL_COMMANDS[@]}" ; then
		echo "🎉 The bootstrap process completed successfully! 💪"
	else
		if ! array_is_empty "${CAN_FAIL_COMMANDS[@]}" ; then
			echo "⚠️ The following commands have failed but it's okay: ⚠️"
			for cmd in "${CAN_FAIL_COMMANDS[@]}"; do
				echo "\t- $cmd"
			done
		fi

		if ! array_is_empty "${FAILED_COMMANDS[@]}" ; then
			echo "💥 The following commands have failed: 💥"
			for cmd in "${FAILED_COMMANDS[@]}"; do
				echo "\t- $cmd"
			done
			ret=1
		fi
	fi

	echo ""
	echo "💡 Note that some of these changes require a logout/restart 💻 to take effect 🚀"

	exit $ret
}
