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

@test "-w gets overwritten by the command line flag -- -w" {
	COMMAND_LINE_ARGS=(-- -w /foo)
	results=$(run_with -w /bar)

	echo "$results"
	exp=(run -w /foo image:1.2.3)
	[[ "$results" = "${exp[@]}" ]]
}

@test "resolving double -- delimiter flags" {
	COMMAND_LINE_ARGS=(--version -- --entrypoint /foo -- -e QUX=quux)
	results=$(run_with --entrypoint /baz)

	echo "${results[@]}"
	exp=(run -e QUX=quux --entrypoint /foo image:1.2.3 --version)
	[[ "$results" = "${exp[@]}" ]]
}

@test "remove flag using the ! bang option" {
	COMMAND_LINE_ARGS=(--version -- !--rm)
	results=$(run_with --rm -it)

	echo "${results[@]}"
	exp=(run -it image:1.2.3 --version)
	[[ "$results" = "${exp[@]}" ]]
}

@test "contains returns boolean based on need vs haystack" {
	results=$(contains "-it" "--rm -it")
	echo "$results"
	exp=true
	[[ "$results" = "$exp" ]]
}

@test "pop removes the given from flag(s) from annother array of flags" {
	args=("--rm -it --entrypoint foo")
	results=$(pop "-it --rm" ${args[@]})
	echo "$results"
	exp=(" --entrypoint foo") # FIXME what is with the extra space before --entrypoint...?
	[[ "$results" = "${exp[@]}" ]]
}
