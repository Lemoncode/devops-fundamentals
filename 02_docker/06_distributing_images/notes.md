## Distributing images

### Saving Docker Images

We can create a backup that can be used later with `docker load`

We can save the images as `.tar` or `.tar.gz`


```bash
docker save busybox > busybox.tar
ls -sh busybox.tar
5520 busybox.tar
```

Instead of using `>` we can use `--output` or `-o` flag. To save the image to `.tar.gz`

```bash
docker save myimage:latest | gzip > myimage_latest.tar.gz
```

### Loading Docker Images

From a `saved image` we can `load` the image. `docker load`, loads an image from a `tar` archvive or _STDIN_.

```bash
docker load < busybox.tar
```

We can also use `--input` flag instead `<`.

This is no the way to work with images, there are better ways. 

## Docker Registry

[Docker Registry Docs]('https://docs.docker.com/registry/)

> Docker Registry is a server side application which stores and helps you to distribute Docker images.

### Why use it

* tightly control where your images are being stored
* fully own your images distribution pipeline
* integrate image storage and distribution tightly into your in-house development workflow

As alternative, if we don't want to mantain our own registry we can found cloud solutions, and of course [Docker Hub]('https://hub.docker.com/)

### Creating a local registry

1. We can easily run our own local registry using the image `registry:2`. Yes, a Docker Registry can also be a Docker Container.

```bash
docker run -d -p 5000:5000 --name registry registry:2
```

2. Now we have a registry on `host` running as a container, we can push images against this _local_ registry. Notice that we have to prefix the image name, with the registry name

```bash
docker tag myapp localhost:5000/myapp
docker push localhost:5000/myapp
curl http://localhost:5000/v2/_catalog
{"repositories":["myapp"]}
```

3. Now if we remove the images from local, and `run` against the the new registry, we can verify, that the regsitry exposed on port 5000, is working:

```bash
docker rmi myapp localhost:5000/myapp
docker run -d -p 8080:8080 --name myapp localhost:5000/myapp
```

Obviously for a production environment we have more requirements, such as user management and TLS certificates. The good news, is that is something that we can configure with this image.

## Docker Hub

Open a new account on Docker Hub

### Docker Hub Login

```bash
docker login ...
```

By default we're registering against Docker Hub, the following commands are equivalent

```bash
docker login 
docker login docker.io
docker login index.docker.io/v1/
```

We can see our settings on `./.docker/config.json`

```bash
$ cat ./.docker/config.json 
{
        "auths": {
                "https://index.docker.io/v1/": {},
                "vps413835.ovh.net:444": {}
        },
        "HttpHeaders": {
                "User-Agent": "Docker-Client/19.03.13 (darwin)"
        },
        "credsStore": "osxkeychain",
        "experimental": "disabled",
        "stackOrchestrator": "swarm"
}
```

### Docker Hub Tag

We already know, that we can tag images using the following command

```bash
$ docker tag ...
```

### Docker Hub Pull

* If we want to push images to `Docker Hub`, we have to do the following steps

1. `tag` the image with Docker Hub user

```bash
$ docker tag myapp <user>/myapp
```

2. `push` with the image tagged with our Docker Hub user

```bash
$ docker push <user>/myapp
```

We can access our user, using the following `url`

```
google https://hub.docker.com/u/<user>
```

### Docker Hub Push

To `pull` an image to Docker Hub, as well as with `push`, we have to prefix the image with the user

```bash
$ docker pull <user>
```


cat .docker/config.json 
{
        "auths": {
                "localhost:5000": {
                        "auth": "bWFudTptYW51"
                }
        }
}