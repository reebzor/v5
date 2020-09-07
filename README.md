# tomreeb.com

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/tomreeb/dotcom)


This is my [personal website](https://tomreeb.com)

Credit to [Styleshout's Ceevee](http://www.styleshout.com/free-templates/ceevee/) web template

This site runs in Docker now. [DockerHub](https://hub.docker.com/r/tomreeb/dotcom/)

## Pre-Install

You need to have `Docker` installed and configured. In order to run tests you need to install `Goss`.

### MacOS via Homebrew

```bash
   brew tap rajatvig/rajat
   brew install docker goss
```

### Linux

```bash
    yum -y install docker
    curl -fsSL https://goss.rocks/install | sh
```

## How to Use

* `$ make build` Builds a container from the Dockerfile
* `$ make build` Builds a container from the Dockerfile without cache
* `$ make run` Runs the container
* `$ make lint` Runs a linter against the Dockerfile
* `$ make test` Runs tests via [Goss](https://github.com/aelsabbahy/goss)
* `$ make shell` Runs the container and logs into the shell
* `$ make rmi` Removes the container image
* `$ make clean` Kills and removes the container
* `$ make release` Releases the container by building then pushing

### Variables

* `$ make build -e VERSION=0.1` Builds a container from the Dockerfile and tags it version 0.1
* `$ make run -e PORTS="-p 80:80"` Runs the container in daemon mode mapping container port 80 to host port 80
