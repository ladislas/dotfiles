#!/usr/bin/env zsh

if is_ci && [ "$1" = "sudo" ] && [ "$2" = "-v" ]; then
	return 0
fi

verbose=false
super_verbose=false
can_fail=false

case "$1" in
	-v|--verbose)
		verbose=true
		shift
		;;
	-vv)
		verbose=true
		super_verbose=true
		shift
		;;
esac

if [ "$1" = "-x" ]; then
	can_fail=true
	shift
fi

command_display="$*"
printf 'Running %s ... ' "$command_display"

if is_dry_run; then
	echo '✅ (dry run)'
	return 0
fi

: > "$TEMP_FILE"
start_seconds=$(date +%s)
"$@" > "$TEMP_FILE" 2>&1
cmd_result=$?
end_seconds=$(date +%s)
duration="$((end_seconds - start_seconds))s"

if [ $cmd_result -eq 0 ]; then
	echo "✅ ($duration)"
	if [[ "$super_verbose" == true ]]; then
		cat "$TEMP_FILE"
	fi
	return 0
fi

echo "❌ ($duration)"

if [[ "$verbose" == true ]]; then
	cat "$TEMP_FILE"
fi

if [[ "$can_fail" == true ]]; then
	CAN_FAIL_COMMANDS+=("$command_display")
	return 0
fi

FAILED_COMMANDS+=("$command_display")
list_failed_commands
