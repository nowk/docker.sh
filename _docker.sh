# vim: set filetype=sh :

# COMMAND_LINE_ARGS is a copy of $@. This is primarily here to help with tests.
COMMAND_LINE_ARGS=("$@")

# docker_normalize_flags traverse arguments and allows for specific overwrites 
# of certain flags returning a new array with specified duplicates to take the
# last given value
docker_normalize_flags() {
	_args=("$@")
	args_=()
	i=0
	j=$(($# + 1))
	while [ $i -lt $j ] ; do
		arg="${_args[i]}"
		case "$arg" in
			--entrypoint)
				i=$((i + 1)) # additional incrementation required
				DOCKER_ENTRYPOINT="--entrypoint ${_args[i]}"
			;;
			--entrypoint=*)
				DOCKER_ENTRYPOINT="$arg"
			;;
			--)
				# we want to remove any additional -- delimiters that might 
				# be set due to chaining
			;;
			!-*)
				# ignore !-*, these are flags to be removed
			;;
			*)
				args_+=("$arg ")
			;;
		esac
		i=$((i + 1))
	done
	args_+=(" $DOCKER_ENTRYPOINT") # add the --entrypoint
	echo "${args_[@]}"
}

# get_rm_flags returns a list of flags that should be removed, these flags
# start with an ! (bang), eg !--rm
get_rm_flags() {
	_args=("$@")
	args_=()
	i=0
	j=$(($# + 1))
	while [ $i -lt $j ] ; do
		arg="${_args[i]}"
		case "$arg" in
			!-*)
				args_+=("${arg[@]:1} ") # remove ! off of the flag
			;;
		esac
		i=$((i + 1))
	done
	echo "${args_[@]}"
}

# pop removes one or more values (as an array) from another array of values
# returning a new array with the popped off values removed
pop() {
	pop_args=($1)
	_args=("$@")
	# odd quirk on passing args through multiple functions, to be honest I have
	# no clue why this works...
	_args=${_args[@]:${#_args[@]}}
	args_=()
	i=0
	j=${#_args[@]}
	while [ $i -lt $j ] ; do
		arg="${_args[i]}"

		i=$((i + 1)) # increment here so we can continue

		ok=$(contains "$arg" "${pop_args[@]}")
		if [ $ok = true ] ; then
			continue
		fi
		args_+=("$arg")
	done
	echo "${args_[@]}"
}

# contains returns a boolean based on whether a single value is contained within
# an array of values
contains() {
	args=("$@")
	needle="${args[@]:0:1}"
	haystack=(${args[@]:1})
	i=0
	j=${#haystack[@]}
	while [ $i -lt $j ] ; do
		if [[ "$needle" = "${haystack[i]}" ]] ; then
			echo true
			return
		fi
		i=$((i + 1)) # increment
	done
	echo false
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
	options=("$@" "${COMMAND_LINE_ARGS[@]:$i+1}")        # merge with run_with params
	rm_flags=$(get_rm_flags "${options[@]}")             # get the flags to be removed
	options=($(docker_normalize_flags "${options[@]}"))  # normalize the flags
	options=($(pop "${rm_flags[@]}" "${options[@]}"))    # pop off any flags we need removed

	run=("run" "${options[@]}" "$DOCKER_IMAGE" "${cmd[@]}")
	echo ${run[@]}
}
