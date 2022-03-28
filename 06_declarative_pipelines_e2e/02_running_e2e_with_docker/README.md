# Running e2e with Docker

Right now we're asking to ourselves, to run this on the Jenkins server I just need node, cool.. Well the reallity is that we try this on server gets a bit nasty with dependencies. Thanks heaven, we have a Docker image for this purpose.

## Creating a Docker image for running e2e

Create `front/Dockerfile.e2e`

```Dockerfile
FROM cypress/base:10

COPY . .

RUN npm install

RUN npm install cypress

RUN $(npm bin)/cypress verify
```

## Running e2e in a Docker container

```bash
$ docker build -t jaimesalas/front-e2e:0.0.1 -f Dockerfile.e2e .
```

```bash
$ docker run -it jaimesalas/front-e2e:0.0.1 npm run test:e2e:local
```

## Creating a Jenkinsfile

Create `front/Jenkinsfile`

```groovy
def image

pipeline {
    agent any 
    stages {
        stage('Build e2e runner') {
            steps {
                script {
                    image = docker.build(
                        "jaimesalas/e2e", 
                        "--pull -f $WORKSPACE/06_declarative_pipelines_e2e/02_running_e2e_with_docker/front/Dockerfile.e2e $WORKSPACE/06_declarative_pipelines_e2e/02_running_e2e_with_docker/front"
                        )
                }
            }
        }
        stage('e2e') {
            steps {
                script {
                    docker.script.sh(script: "docker run --rm jaimesalas/e2e npm run test:e2e:local", returnStdout: false)
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