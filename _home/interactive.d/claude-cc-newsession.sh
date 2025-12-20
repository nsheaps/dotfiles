#!/usr/bin/env bash
# Creates new Claude workspace sessions (includes cc-tmp)

cc-newsession () {
	CURRENT_DIR="$PWD"
	is_temp='false'
	if [[ "$1" == "--temp" ]]
	then
		is_temp='true'
		shift
	elif [[ -n "$1" ]]
	then
		echo "pass '--temp' to create a temporary claude workspace which is deleted on exit."
		return 1
	fi
	CLAUDE_ARGS="$@"
	NOW="$(date +%s)"
	WS_DIR="$HOME/.claude/tmp/workspace-$NOW"
	cleanup () {
		echo "is_temp=$is_temp"
		if [[ $is_temp == 'true' ]]
		then
			if [[ -d "$WS_DIR" ]]
			then
				cd "$HOME"
				rm -rf "$WS_DIR"
				echo "\nDeleted temporary workspace directory:\n\t$WS_DIR"
			else
				echo "\nNothing to clean up"
			fi
		else
			echo "\nLeaving workspace directory intact at:\n\t$WS_DIR"
		fi
	}
	trap cleanup EXIT
	IS_TMP_ARG=""
	if [[ $is_temp == 'true' ]]
	then
		IS_TMP_ARG="--temp"
		echo "Creating temporary workspace directory at:\n\t$WS_DIR"
	fi
	cc-runclaude "$WS_DIR" "$IS_TMP_ARG" "$@"
}

cc-tmp () {
	cc-newsession --temp "$@"
}
