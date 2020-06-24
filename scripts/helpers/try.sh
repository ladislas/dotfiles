#!/usr/bin/env zsh

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

cmd_result=0

if [[ ! -n $DRY_RUN ]]; then
	if [[ $1 =~ "sudo" ]]; then
		shift
		sudo script -q $TEMP_FILE $@ > /dev/null 2>&1
	else
		script -q $TEMP_FILE $@ > /dev/null 2>&1
	fi
	cmd_result=$?
fi

end=$(date +%s.%N)

# calculate duration
runtime="$(printf %.2f $(echo "$end-$start" | bc -l))"

# output result
if [ $cmd_result -eq 0 ]; then
	echo "✅ ($runtime)"
	if [[ $super_verbose == true ]]; then
		cat $TEMP_FILE
	fi
else
	echo "❌ ($runtime)"
	FAILED_COMMANDS+=$@
	if [[ $verbose == true ]]; then
		cat $TEMP_FILE
	fi
fi
