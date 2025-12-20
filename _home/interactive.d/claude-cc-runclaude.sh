#!/usr/bin/env bash
# Core function that launches Claude in a workspace directory

cc-runclaude () {
	CURRENT_DIR="$PWD"
	WS_DIR="$1"
	shift
	local is_temp='false'
	if [[ "$1" == "--temp" ]]
	then
		is_temp='true'
		shift
	fi
	back_to_cwd () {
		cd "$CURRENT_DIR"
	}
	trap back_to_cwd EXIT
	append_system_prompt="$(cat << EOPROMPT
The user has launched you in an ephemeral workspace located at $WS_DIR.
$(if [[ $is_temp == 'true' ]]; then
    echo "This workspace is temporary and will be deleted when the user exits Claude."
fi)

This workspace is empty by default. Clarify with the user why it is needed if it is unclear from their prompt.

Assume the user is not an expert at prompt engineering. When they make a request, first apply a critical thinking
lens by starting with:
  To fulfill this request, I should start by improving the prompt
  Let me rewrite the user's prompt to be one that I would use with an AI agent to perform this task.
  This prompt should be detailed enough that the AI Agent can complete the task in one-shot.
  If the user's request doesn't contain enough detail to assure a one-shot execution, ask for clarification from the user.

Once you have improved the prompt, proceed to complete the user's request as best as you can.
EOPROMPT
)"
	mkdir -p "$WS_DIR"
	cd "$WS_DIR"
	printf "Launching Claude...\n" "$WS_DIR"
	claude --add-dir="$PWD" --append-system-prompt="$append_system_prompt" "$@"
}
