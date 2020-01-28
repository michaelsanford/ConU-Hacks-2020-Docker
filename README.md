# "Docker, what even is it?"

## ConU Hacks 2020 Docker talk

Stelvio Inc

Michael Sanford

### Building

1. [Install Docker](https://hub.docker.com/editions/community/docker-ce-desktop-windows) (I use Edge in my examples)
2. Run `build.ps1` (or `build.ps1 -d` if you want to detach)

To quit, <kbd>Ctrl + C</kbd> and wait for the stack to exit gracefully.

#### Read the builder

Read the build script, it's part of what was taught!

You first need to build images from both projects (detailed below), and then use docker-compose to bring up the _images_ into running _containers_, and assemble them into a _stack_.

(You can ignore the `Write-Host`s that was just for visual landmarking to know what's happening when.)

### Slides

Here are the slides: https://docs.google.com/presentation/d/10TfB8PTp50rpvloXovdd4n4fAMhNrqYhmLqllwr-Pe8/


## Explanation of the Code

The slides give a basic overview of the anatomy of Docker. The code in this repo serves as a companion that was presented live.

### Project A

This represents a simple server written in Python and executed with a Python container.

The `Dockerfile`, in the root of that service, is used to build the `project-a:latest` _image._ Since it's a Python service, we
- start off with a Python 3 base image from DockerHub,
- create and cd into the working directory `/opt/conu`,
- copy files from the root of the Project A/ folder into the container at the current directory
- open port 8080 on the firewall
- instruct this image what to run when it starts as a _container_

Notice that the port we expose matches the port the service binds to itself in `hello.py`. Once this _image_ is run (executed) as a _container_ it will be completely sequestered from other containers and will not be port-mapped to/accessible from the host. So, yes, you can have multiple images declare `EXPOSE` instructions that are all on the same port. You address this in your `docker-compose.yml`

This `Dockerfile` pattern is the most common, default pattern.

### Project B

This project is a simple Go application that does much the same thing as the Python app. However, since Go is a compiled language and does not require an interpreter, we can use a different pattern to make our image, called the ["multi-stage builder pattern"](https://docs.docker.com/develop/develop-images/multistage-build/). And here is a [condensed explanation I wrote on StackOverflow](https://stackoverflow.com/a/59778752/114900).

In this pattern, you declare more than one build stages, and only copy forward the pieces of the build you require.

So we start with a golang base image fixed at a specific version, copy the source code into it and compile it within the image. This stage is called "builder" (it can be any string).

Now, the second stage uses the special [`scratch`](https://hub.docker.com/_/scratch) as the base image, which contains basically nothing. We don't need the whole Go build toolchain, nor anything else, really to get our plain binary to run.

We copy the source (because I was lazy) and the binary artifact from the builder into the new scratch image, expose a port, and run it.

### Why the two patterns?

When you finish this tutorial and run `docker image ls` you'll see why: the `project-a` image sits around 980 MB, because it contains the entire python runtime, whereas `project-b` sits around 7 MB, because it contains only the artifacts we copied into it.

We can get away with this because Docker containers are not virtual machines, but namespaces on top of linux, so already have access to an operating system!

### MariaDB

There is no Dockerfile for that... See below

### `docker-compose.yml`

This is what ties together all of your containers into a stack. It's [a well-documented YAML configuration](https://docs.docker.com/compose/compose-file/) and nothing more.

We declare `services:` with names `ProjectA`, `ProjectB` and `MariaDB`. These become the host names that you use to communicate between containers. So if project A actually needed a database connection, its database host would simply be `"MariaDB"` and Docker would take care of routing it to the right container, as long as it's within the same stack. You allow a container to communicate with another container using the `links:` list, which I believe is customiarily is declared on the client end of the connection: I'm linking Project A to the MariaDB.

Port mappings between the container and the host are declared here as well. For readability, I used different ports in each container, but I did not have to. I could have `EXPOSE 8080` in both ProjectA and ProjectB, and then simply mapped them to different host ports, here. The mapping order is `host:container`.

Lastly note the `depends_on:` directives. The docker-compose lists the services in order ProjectA, ProjectB, MariaDB. However, given the dependency links, you will see that `MariaDB` comes up _first, then_ `ProjectB`, _then_ `ProjectA`.

#### But MariaDB?!

If you want to run container from an image and only need a little bit of customization, like a database with a user and root password, you can delcare the image and its configuration values directly within the docker-compose, as I have done with `MariaDB`. You use exactly the same name as you would in a `FROM` line in a `Dockerfile`.

The specific configurations are usually passed as environment variables and are documented for each individual base image, as they are specific to each base image.

This is why you must `docker build . -t "some-name"` each of your images beforehand: the `image:` names given for your custom images are the ones you gave it when you built them.

## Docker image resolution

When `docker-compose.yml` (or the `docker run` command) looks for a named image, it will
- first look in the local cache,
- and then reach out to the network to DockerHub (and any other registries you've specified)

## A note on `image:latest`

This can be troublesome because latest changes based on when images were pushed. If you're building a Go app using the builder pattern, you're probably better using a specific version tag, because the compiler can change substantially between releases.

If you're using a database engine, your volume might break between versions (happened to us).
