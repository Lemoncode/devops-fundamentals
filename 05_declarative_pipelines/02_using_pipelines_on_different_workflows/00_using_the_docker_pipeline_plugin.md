# Demo 1

Powering pipelines with Docker.

## Pre-reqs

Run Jenkins in [Docker](https://www.docker.com/products/docker-desktop):

```bash
$ ./start_jenkins.sh <jenkins-image> <jenkins-volume-certs> <jenkins-volume-data>
```

Before start remove previous pipelines

## 1.1 Using a container as a build agent

Create a new directory *05_declarative_pipelines/src_tmp/jenkins-demos-review/02*. Unzip code from `05_declarative_pipelines` directory

```bash
unzip code.zip -d ./src_temp/jenkins-demos-review/02
```

Create `02/demo1/1.1/Jenkinsfile`

```groovy
pipeline {
    agent {
        docker {
            image 'node:alpine3.12'
        }
    }
    stages {
        stage('Verify') {
            steps {
                sh '''
                  node --version
                  npm version
                '''
                sh 'printenv'
                sh 'ls -l "$WORKSPACE"'
            }
        }
        stage('Build') {
            steps {
                dir("$WORKSPACE/02/src") {
                    sh '''
                      npm install
                      npm run build
                    '''
                }
            }
        }
        stage('Unit Test') {
            steps {
              dir("$WORKSPACE/02/src") {
                sh 'npm test'
              }
            }
        }
    }
}
```

Log into Jenkins at http://localhost:8080 with `lemoncode`/`lemoncode`.

- New item, pipeline, `demo1-1`
- Select pipeline from source control
- Git - https://github.com/JaimeSalas/jenkins-pipeline-demos
- Path to Jenkinsfile  - `02/demo1/1.1/Jenkinsfile`
- Run

> Walk through the [Jenkinsfile](./02/demo1/1.1/Jenkinsfile)

```groovy
agent { 
    agent {
        docker {
            image 'node:alpine3.12'
        }
    }
}
```

This is the part that is different now, we're specifying that the agent is a `docker container`, and the image `'node:alpine3.12'` that we want to use. So what happens when this build runs is that the Jenkins starts a container from this image.

All the shell commands are actually executed inside the container.

I can use `docker` as my build agent, and I don't need to have a machine with the `node` installed. Any Jenkins server, with docker install could spin up a an agent with `node` and execute the whole build pipeline inside that container, with Jenkins taking care of moving files around and setting up the environment of the container for me.

## 1.2 Custom container agents

* Create `02/Dockerfile`

```Dockerfile
FROM node:alpine3.12 as builder

WORKDIR /build

COPY ./src .

RUN npm install

RUN npm run build

FROM node:alpine3.12 as application

WORKDIR /opt/app

COPY ./src/package.json .

COPY ./src/package-lock.json .

COPY --from=builder /build/app .

RUN npm i --only=production

ENTRYPOINT ["node", "app.js"]
```


* Create `02/demo1/1.2/Jenkinsfile`

```groovy
pipeline {
    agent {
        dockerfile {
            dir '02/src'
        }
    }
    stages {
        stage('Verify') {
            steps {
                sh'''
                    node --version
                    npm version
                '''
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t jaimesalas/jenkins-pipeline-demos:0.0.1 .'
            }
        }
        stage('Smoke Test') {
            steps {
                sh 'docker run jaimesalas/jenkins-pipeline-demos:0.0.1'
            }
        }
    }
}
```

Push changes

- Copy item, `demo1-2` from `demo1-1`
- Path to Jenkinsfile `02/demo1/1.2/Jenkinsfile`
- Run - fails

> Walk through the [Dockerfile](../Dockerfile) and the [Jenkinsfile](./02/demo1/1.2/Jenkinsfile)

```groovy
pipeline {
    agent {
        dockerfile {
            dir '02/src'
        }
    }
    stages {
        stage('Verify') {
            steps {
                sh'''
                    node --version
                    npm version
                '''
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t jaimesalas/jenkins-pipeline-demos:0.0.1 .'
            }
        }
        stage('Smoke Test') {
            steps {
                sh 'docker run jaimesalas/jenkins-pipeline-demos:0.0.1'
            }
        }
    }
}
```

1. The agent block we're specifying a `Dockerfile`, we're telling Jenkins that is a Dockerfile inside my repo, inside my directoty `02`, and I want to build an image from that `Dockerfile` and the run a container for my build. If we have a look to that `Dockerfile` we notice that is the image of the build of the application, and Jenkins is not expecting that.

But what people often do when they're looking at this approach is they get confused as to what that `Dockerfile` is meant to do. So if I look at that `Dockerfile`, this `Dockerfile` is actually a full build of my project. 

So it starts from the dotnet core SDK and it does the dotnet build and publish, and then it packages my applications, I had a Docker image. And this is not what Jenkins is expecting to. When Jenkins gives you the docker file option, inside the agent buster build an image to use as the build agent is not to build your application. 

So what this pipeline things is doing is asking Jenkins to compile the application, using the `Dockerfile` in the Repo and then run the Verify Command to print out all the SDK that got used and then do a smoke test by running a container from the image that's been built. 

But these are separate things, the image that was built as part of the `Dockerfile` that's an SDK may just not meant to be used by Jenkins taken part of your application. 

So it's going to see how that looks. So if we check this build its failed as expected, we go and look at the output. I could see all the lines for my `Dockerfile` being executed, and then I get these really weird Jenkins error messages telling me it is trying to do something with the container on. 

The reason this is failing is because Jenkins is trying to run that container as a build agent but actually that container has been packaged to run my application. There is no any uses a build agent. So this Jenkinsfile, I'm trying to run the pipeline doesn't make any sense because the `Dockerfile` that I'm using is the `Dockerfile` for my application. So I can use that as a build agent because it doesn't have any sdk inside it. 

> Walk through the fixed [Dockerfile.node](../Dockerfile.node) and [Jenkinsfile.fixed](./1.2/Jenkinsfile.fixed)

* Create `Dockerfile.node`

```Dockerfile
FROM node:alpine3.12 as builder

ENV LEMONCODE_VAR=lemon
```

* And create `02/demo1/1.2/Jenkinsfile.fixed` as follows

```groovy
pipeline {
    agent {
        dockerfile {
            dir '02/src'
            filename 'Dockerfile.node'
        }
    }
    stages {
        stage('Verify') {
            steps {
                sh '''
                  node --version
                  npm version
                '''
                sh 'printenv'
                sh 'ls -l "$WORKSPACE"'
            }
        }
        stage('Build') {
            steps {
                dir("$WORKSPACE/02/src") {
                    sh '''
                        npm install
                        npm run build
                    '''
                }
            }
        }
        stage('Unit Test') {
            steps {
                dir("$WORKSPACE/02/src") {
                sh 'npm test'
              }
            }
        }
    }
}
```

```groovy
agent {
    dockerfile {
        dir '02/src'
        filename 'Dockerfile.node' // [1]
    }
}
```

1. What the `Dockerfile` agent is for is when you want to customize the sdk. So instead of trying to build my whole application in the `Dockerfile`, which is what I'm doing now, the purpose of that is to take an official SDK image like the dotnet core image and then make any customization is that you want to make So in this case, I'm just adding another environment variable. So this `Dockerfile` is to run my agents and not build my application

- Change Jenkinsfile to `02/demo1/1.2/Jenkinsfile.fixed`
- Run again

## 1.3 The Docker pipeline plugin

* Create `02/demo1/1.3/Jenkinsfile`

```groovy
def image

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    image = docker.build("jaimesalas/jenkins-pipeline-demos:0.0.1", "--pull -f 02/src/Dockerfile 02/src")
                }
            }
        }
        stage('Smoke Test') {
            steps {
                script {
                    container = image.run()
                    container.stop()
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                        image.push()
                    }
                }
            }
        }
    }
}
```

- Credentials in Jenkins - Docker Hub
- Copy item, `demo1-3` from `demo1-1`
- Path to Jenkinsfile `02/demo1/1.3/Jenkinsfile`
- Run

> Walk through the [Jenkinsfile](.02/demo1/1.3/Jenkinsfile) and [Dockerfile](../Dockerfile)

```groovy
def image

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    image = docker.build("jaimesalas/jenkins-pipeline-demos:0.0.1", "--pull -f 02/Dockerfile 02") // [1]
                }
            }
        }
        stage('Smoke Test') {
            steps {
                script {
                    container = image.run() // [2]
                    container.stop()
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "docker-hub", url: ""]) { // [3]
                        image.push()
                    }
                }
            }
        }
    }
}
```

Here we're using the `Docker Pipeline plug-in` gives a hugh amount of control over interacting `Jenkins` and the `Docker engine`.

1. We use the `docker` object which is part of the `Docker Pipeline plug-in`, and we run the `build` method, telling it the name of the docker image to produce and telling where to find the `Dockerfile`
2. Instead of running the dotnet commands, we're running a new container from the previous build image
3. In the final stage we're publshing that image

## Adding Jenkins credentials

> https://www.jenkins.io/doc/book/using/using-credentials/#:~:text=From%20the%20Jenkins%20home%20page,Add%20Credentials%20on%20the%20left.
> https://appfleet.com/blog/building-docker-images-to-docker-hub-using-jenkins-pipelines/#:~:text=On%20Jenkins%20you%20need%20to,this%20credential%20from%20your%20scripts.
