#!/usr/bin/env bats
# vim: set filetype=sh :

# include file to test
. "$(pwd)/_docker.sh"

@test "define default flags" {
	results=$(run_with --rm -it --entrypoint /foo)

	exp=(run --rm -it --entrypoint /foo)
	[[ "$results" = "${exp[@]}" ]]
}

@test "--entrypoint gets overwritten by the command line flag -- --entrypoint" {
	COMMAND_LINE_ARGS=(-- --entrypoint /foo)
	results=$(run_with --entrypoint /bar)

	exp=(run --entrypoint /foo)
	[[ "$results" = "${exp[@]}" ]]
}
