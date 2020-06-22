#!/usr/bin/env zsh

#
# Helpers
#

# create tmp file & schedule delete if error
tmp_file=$(mktemp)
trap "rm -f $temp_file" 0 2 3 15

typeset -Ux failed_commands=()

function try {

	if [[ -n $CI_TEST ]]; then
		if [[ "$@" =~ "sudo -v" ]]; then
			return 0
		fi
	fi

	verbose=false
	super_verbose=false

	# set output level
	if [[ $1 =~ "-v" || $1 =~ "--verbose" ]]; then
		verbose=true
		if [[ $1 =~ "-vv" ]]; then
			verbose=true
			super_verbose=true
		fi
		shift
	fi

	start=$(date +%s.%N)

	# execute command
	echo -ne "Running $@ ... "
	script -q $tmp_file $@ > /dev/null 2>&1
	cmd_result=$?

	end=$(date +%s.%N)

	# calculate duration
	runtime="$(printf %.2f $(echo "$end-$start" | bc -l))"

	# output result
	if [ $cmd_result -eq 0 ]; then
		echo "✅ ($runtime)"
		if [[ $super_verbose == true ]]; then
			cat $tmp_file
		fi
	else
		echo "❌ ($runtime)"
		failed_commands+=$@
		if [[ $verbose == true ]]; then
			cat $tmp_file
		fi
	fi
}

function list_failed_commands {
	echo ""
	if [ ${#failed_commands[@]} -eq 0 ]; then
		echo "🎉 The bootstrap process completed successfully! 💪"
	else
		echo "⚠️ The following commands have failed:"
		for cmd in $failed_commands; do
			echo "\t- $cmd"
		done
	fi
}
