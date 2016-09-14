# vim: set filetype=sh :

# COMMAND_LINE_ARGS is a copy of $@. This is primarily here to help with tests.
COMMAND_LINE_ARGS=("$@")

# docker_normalize_flags traverse arguments and allows for specific overwrites 
# of certain flags returning a new array with specified duplicates to take the
# last given value
docker_normalize_flags() {
	args=()
	i=1
	j=$(($# + 1))
	while [ $i -lt $j ] ; do
		arg="${!i}"
		case "$arg" in
			--entrypoint)
				next_arg_index=$((i + 1))
				DOCKER_ENTRYPOINT="--entrypoint ${!next_arg_index}"

				i=$((i + 1)) # additional incrementation required
			;;
			--entrypoint=*)
				DOCKER_ENTRYPOINT="$arg"
			;;
			*)
				args+=("$arg ")
			;;
		esac
		i=$((i + 1))
	done
	args=("${args[@]}" "$DOCKER_ENTRYPOINT")
	echo ${args[@]}
}

# docker_split_flag_index find the index for -- which is the split dellimiter
# for additional docker based flags, eg ./
docker_split_flag_index() {
	i=0
	for arg in "$@" ; do
		if [ "$arg" = "--" ] ; then break; fi
		i=$((i + 1))
	done

	echo $i
}

# run_with provides a way to inject "default" options and get a full set of
# docker run arguments with any additional `--` parsed docker flags
run_with() {
	# parse out the actual command/flags
	i=$(docker_split_flag_index "${COMMAND_LINE_ARGS[@]}")
	cmd=("${COMMAND_LINE_ARGS[@]:0:$i}")

	# remove docker command arguments out from command line arguments, leaving
	# only the docker flags
	options=("$@" "${COMMAND_LINE_ARGS[@]:$i+1}")   # merge with run_with params
	options=($(docker_normalize_flags "${options[@]}"))

	run=("run" "${options[@]}" "$DOCKER_IMAGE" "${cmd[@]}")
	echo ${run[@]}
}
