# tomreeb.com
This is my personal website, now located at https://tomreeb.com.

Credit to Styleshout's Ceevee web template http://www.styleshout.com/free-templates/ceevee/

This site runs in Docker now. You can find it on DockerHub at https://hub.docker.com/r/tomreeb/dotcom/

## How to Use

`$ make build` Builds a container from the Dockerfile
`$ make push` Pushes the container to registry
`$ make run` Runs the container
`$ make start` Runs the container in daemon mode
`$ make shell` Runs the container and logs into the shell
`$ make stop` Stops the running container
`$ make rm` Removes the container
`$ make release` Releases the container by building then pushing

### Variables

`$ make build -e VERSION=0.1` Builds a container from the Dockerfile and tags it version 0.1
`$ make start -e PORTS="-p 80:80"` Runs the container in daemon mode mapping container port 80 to host port 80

**Note:** Variable defaults can be set in make_include file