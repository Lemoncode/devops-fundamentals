# Running e2e with Docker

Right now we're asking to ourselves, to run this on the Jenkins server I just need node, cool.. Well the reallity is that we try this on server gets a bit nasty with dependencies. Thanks heaven, we have a Docker image for this purpose.

## Docker image front

Create `front/nginx.conf`

```ini
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    server {
        listen 8081;
        server_name  localhost;

        root   /usr/share/nginx/html;
        index  index.html index.htm;
        include /etc/nginx/mime.types;

        gzip on;
        gzip_min_length 1000;
        gzip_proxied expired no-cache no-store private auth;
        gzip_types text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript;

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
```

Create `front/Dockerfile`

```Dockerfile
FROM node:20-alpine as build

WORKDIR /opt/build 

COPY ./src ./src

COPY .babelrc .

COPY *.json ./

COPY webpack.config.js .

RUN npm ci

RUN npm run build

FROM nginx:alpine as app 

COPY nginx.conf /etc/nginx/nginx.conf 

WORKDIR /usr/share/nginx/html 
COPY --from=build /opt/build/dist/ .

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]
```

## Creating a Docker image for running e2e

Create `e2e/Dockerfile`

```Dockerfile
FROM cypress/base:20.10.0
WORKDIR /app

# dependencies will be installed only if the package files change
COPY package.json .
COPY package-lock.json .

# by setting CI environment variable we switch the Cypress install messages
# to small "started / finished" and avoid 1000s of lines of progress messages
# https://github.com/cypress-io/cypress/issues/1243
ENV CI=1
RUN npm ci
# verify that Cypress has been installed correctly.
# running this command separately from "cypress run" will also cache its result
# to avoid verifying again when running the tests
RUN npx cypress verify
```

## Running e2e in a Docker container


```bash
# change diretory to front
docker build -t jaimesalas/dd-frontend:0.0.1 -f Dockerfile .
```

```bash
# change diretory to e2e
docker build -t jaimesalas/dd-e2e:0.0.1 -f Dockerfile .
```

- https://docs.docker.com/desktop/networking/#use-cases-and-workarounds-for-all-platforms

```bash
# on e2e directory
docker run -it -v $PWD/cypress:/app/cypress \
 -e "CYPRESS_baseUrl=http://host.docker.internal:8081" \
 -v $PWD/cypress.config.js:/app/cypress.config.js \
 jaimesalas/dd-e2e:0.0.1 npm run cypress:run
```

> Notice that we're using `host.docker.internal`

## Creating a Jenkinsfile

Create `front/Jenkinsfile`

```groovy
def image 

pipeline {
    agent any
    stages {
        stage('Build front image') {
            steps {
                script {
                    front = docker.build(
                        "jaimesalas/front",
                        "--pull -f $WORKSPACE/06_declarative_pipelines_e2e_refactor/02_running_e2e_with_docker/front/Dockerfile $WORKSPACE/06_declarative_pipelines_e2e_refactor/02_running_e2e_with_docker/front"
                    )
                }
            }
        }
        stage('Build e2e image') {
            steps {
                script {
                    e2e = docker.build(
                        "jaimesalas/front",
                        "--pull -f $WORKSPACE/06_declarative_pipelines_e2e_refactor/02_running_e2e_with_docker/e2e/Dockerfile $WORKSPACE/06_declarative_pipelines_e2e_refactor/02_running_e2e_with_docker/e2e"
                    )
                }
            }
        }
    }
}
```

Because we have a complicated structure of demos, the above paths are a little hard to follow, developing the example alone the path is easier

```groovy
/*diff*/
script {
    image = docker.build("jaimesalas/e2e", "--pull -f ./front/Dockerfile.e2e ./front")
}
/*diff*/
```
