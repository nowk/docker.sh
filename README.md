# docker.sh

A simple imported bash script to help create docker wrapped executables.


## Example

The example is based on a nodejs executable that runs a docker image of nodejs, bypassing the need to install nodejs directly on the system.

__node__

    #!/bin/bash
    # set: filetype=sh :

    # DOCKER_IMAGE is required
    DOCKER_IMAGE="node:5.12.0"

    # this must come after any DOCKER_... defined variables
    . "$PATH_TO/docker.sh/_dockerh.sh"

    docker $(run_with --rm -it -v $(pwd):/usr/src -w /usr/src --entrypoint /usr/local/bin/node)


The basic setup appends the `run_with` arguemnts to the `run` command

    $ node --version
    # docker run --rm -it -v /path/to/here:/usr/src -v /usr/src --entrypoint /usr/local/bin/node node:5.12.0 --version


To append additional docker flags to the command you can separate docker flags from normal command flags at the end with the `--` delimiter

    $ node ./index.js -- -p 4000:3000
    # docker run --rm -it -v /path/to/here:/usr/src -v /usr/src --entrypoint /usr/local/bin/node -p 4000:3000 node:5.12.0 ./index.js


## License

MIT

