# vim: set filetype=sh :

# traverse $@ and allow for specific overwrites of certain flags
# this creates a new _ARGS array to be used for the rest of the script
_ARGS=()
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
			_ARGS+=("$arg ")
		;;
	esac
	i=$((i + 1))
done

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

_i=$(docker_split_flag_index $_ARGS)
_CND_ARGS=(${_ARGS[@]:0:$_i})
_OPTIONS=(${_ARGS[@]:$_i+1:${#_ARGS[@]}})

# run_with provides a way to inject "default" options and get a full set of
# docker run arguments with any additional `--` parsed docker flags
run_with() {
	args=("run" "$@" "${_OPTIONS[@]}" $DOCKER_IMAGE "${_CND_ARGS[@]}")

	echo ${args[@]}
}
