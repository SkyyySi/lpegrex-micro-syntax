#!/usr/bin/env bash
set -euCo pipefail

declare -g SCRIPT_PATH="${BASH_SOURCE[0]:-$0}" SCRIPT_DIR=''
SCRIPT_PATH=$(realpath --physical -- "$SCRIPT_PATH")
SCRIPT_DIR=$(dirname -- "$SCRIPT_PATH")

cd "$SCRIPT_DIR" || exit 1

declare -g XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CONFIG_HOME=$(realpath --physical -- "$XDG_CONFIG_HOME")

if [[ ! -d "$XDG_CONFIG_HOME" ]]; then
	printf '>>> ERROR: Could not find user config directory "%q"!\n' "$XDG_CONFIG_HOME" >&2

	declare home_config="$HOME/.config"
	home_config=$(realpath --physical -- "$home_config")
	if [[ "$XDG_CONFIG_HOME" != "$home_config" ]]; then
		# shellcheck disable=SC2016
		printf '>>> Note: "$XDG_CONFIG_HOME" was set to a path other than "$HOME/.config".\n' >&2
	fi

	return 1
fi

declare -g MICRO_CONFIG_DIR="$XDG_CONFIG_HOME/micro"
MICRO_CONFIG_DIR=$(realpath --physical -- "$MICRO_CONFIG_DIR")

if [[ ! -d "$MICRO_CONFIG_DIR" ]]; then
	printf '>>> ERROR: Could not find micro config directory "%q"!\n' "$MICRO_CONFIG_DIR" >&2
	printf '>>> It should have been created the first time you launched micro.\n' >&2
	return 1
fi

declare -g MICRO_SYNTAX_DIR="$MICRO_CONFIG_DIR/syntax"
MICRO_SYNTAX_DIR=$(realpath --physical -- "$MICRO_SYNTAX_DIR")

if [[ ! -d "$MICRO_SYNTAX_DIR" ]]; then
	printf '>>> INFO: Could not find micro syntax directory "%q".\n' "$MICRO_SYNTAX_DIR" >&2
	printf '>>> It will be created by this script.\n' >&2
	printf '>>> Note: This is normal if you never added a custom syntax deffinition previously.\n' >&2
fi

mkdir --parents --verbose -- "$MICRO_SYNTAX_DIR"

declare -g SOURCE="$SCRIPT_DIR/lpegrex.yaml"
declare -g DESTINATION="$MICRO_SYNTAX_DIR/lpegrex.yaml"

declare -g -i do_symlink=1

if [[ -f "$DESTINATION" ]]; then
	if [[ "$(realpath --physical -- "$SOURCE")" == "$(realpath --physical -- "$DESTINATION")" ]]; then
		printf '>>> INFO: File "%q" is already a symbolic link pointing to the correct path, no change needed.\n' "$DESTINATION" >&2
		do_symlink=0
	else
		printf '>>> INFO: File "%q" already exists, it will be overwritten.\n' "$DESTINATION" >&2
		rm --force --verbose -- "$DESTINATION"
	fi
fi

if (( do_symlink )); then
	ln --symbolic --verbose -- "$SCRIPT_DIR/lpegrex.yaml" "$DESTINATION"
fi
