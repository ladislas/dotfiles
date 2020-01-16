#!/usr/bin/env zsh

#
# Helpers
#

typeset -U failed_commands=()

function try {

	verbose=false
	super_verbose=false

	# create tmp file & schedule delete if error
	tmp_file=$(mktemp)
	trap "rm -f $temp_file" 0 2 3 15

	# set output level
	if [[ $1 =~ "-v" || $1 =~ "--verbose" ]]; then
		verbose=true
		if [[ $1 =~ "-vv" ]]; then
			verbose=true
			super_verbose=true	
		fi
		shift
	fi

	start=$(date +%S.%N)

	# execute command
	echo -ne "Running $@ ... "
	script -q $tmp_file $@ > /dev/null 2>&1
	cmd_result=$?

	end=$(date +%S.%N)

	# calculate duration
	runtime=$(echo -ne $(printf %.2f $(echo "$end - $start" | bc -l)))

	# output result
	if [ $cmd_result -eq 0 ]; then
		echo "✅ ($runtime)"
		if [ $super_verbose = true ]; then
			cat $tmp_file
		fi
	else
		echo "❌ ($runtime)"
		failed_commands+=$@
		if [ $verbose = true ]; then
			cat $tmp_file
			
		fi
	fi

	rm -rf $tmp_file

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