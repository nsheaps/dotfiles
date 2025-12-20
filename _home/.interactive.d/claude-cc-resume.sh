#!/usr/bin/env bash
# Resumes existing Claude workspace sessions

cc-resume () {
	cc-resumesession
}

cc-resumesession () {
	if ! command -v gum &> /dev/null
	then
		brew install gum
	fi
	OPTIONS=()
	for dir in "$HOME/.claude/tmp/"workspace-*(N)
	do
		[ -d "$dir" ] && OPTIONS+=("$(basename "$dir")")
	done
	RESUME_OPTION="Resume from Claude (claude --resume, opens menu)"
	CANCEL_OPTION="Cancel"
	OPTIONS+=("$RESUME_OPTION")
	OPTIONS+=("$CANCEL_OPTION")
	SELECTED=$(gum choose "${OPTIONS[@]}")
	if [ "$SELECTED" = "$CANCEL_OPTION" ] || [ -z "$SELECTED" ]
	then
		echo "Cancelled."
		return
	elif [ "$SELECTED" = "$RESUME_OPTION" ]
	then
		claude --resume
	else
		WS_DIR="$HOME/.claude/tmp/$SELECTED"
		printf "Resuming Claude session in workspace:\n\t$WS_DIR"
		cc-runclaude "$WS_DIR" "$@"
		echo "\nLeaving workspace directory intact at:\n\t$WS_DIR"
	fi
}
