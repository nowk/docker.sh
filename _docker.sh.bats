#!/usr/bin/env bats
# vim: set filetype=sh :

DOCKER_IMAGE="image:1.2.3"

# include file to test
. "$(pwd)/_docker.sh"

@test "define default flags" {
	results=$(run_with --rm -it --entrypoint /foo)

	exp=(run --rm -it --entrypoint /foo image:1.2.3)
	[[ "$results" = "${exp[@]}" ]]
}

@test "--entrypoint gets overwritten by the command line flag -- --entrypoint" {
	COMMAND_LINE_ARGS=(-- --entrypoint /foo)
	results=$(run_with --entrypoint /bar)

	exp=(run --entrypoint /foo image:1.2.3)
	[[ "$results" = "${exp[@]}" ]]
}

@test "resolving double -- delimiter flags" {
	COMMAND_LINE_ARGS=(--version -- --entrypoint /foo -- -e QUX=quux)
	results=$(run_with --entrypoint /baz)

	echo "${results[@]}"
	exp=(run -e QUX=quux --entrypoint /foo image:1.2.3 --version)
	[[ "$results" = "${exp[@]}" ]]
}
