# Downloading and running Jenkins in Docker

The following steps follows these [Jenkins docs](https://www.jenkins.io/doc/book/installing/docker/)

## macOS/Linux

### 1. Create a network for Jenkis

```bash
docker network create jenkins
```

### 2. Run Docker in Docker

In order to execute Docker commands inside Jenkins nodes, we need `docker:dind`

```bash
docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2
```

### 3. Customise official Jenkins Docker image

```Dockerfile
FROM jenkins/jenkins:2.426.3-jdk17

USER root 

RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

USER jenkins 

RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
```

```bash
docker build -t jenkins-blueocean .
```

### Run Jenkins

```bash
docker run \
  --name jenkins-blueocean \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkins-blueocean 
```

## Starting Jenkins

To unlock Jenkins we have to paste a password, we can find the password inside the running container, run the following command `cat /var/jenkins_home/secrets/initialAdminPassword` to obtain the initial password

```bash
docker container exec -it jenkins-blueocean bash
```

```bash
ls
```

```
bin  certs  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

```bash
cat /var/jenkins_home/secrets/initialAdminPassword 
8b0ee7a1a0214fe0a3029b8232c56087
```

Copy this password into the clipboard and redirect to `localhost:8080`, use it to log in into Jenkins.Now install the suggested plugins and wait until Jenkins finishes.