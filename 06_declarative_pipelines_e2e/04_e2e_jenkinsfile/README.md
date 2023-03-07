# e2e Jenkinsfile

For last we're going to create a pipeline, that makes the same work that the Docker engine does for us.

> Exercise: Build that pipeline

## Solution

On root folder create a new `Jenkinsfile`

```groovy
def front 
def back

def withockerNetwork(Closure inner) {
    try {
        networkId = UUID.randomUUID().toString();
        sh "docker network create ${networkId}";
        inner.call(networkId);
    } finally {
        sh "docker network rm ${networkId}";
    }
}

pipeline {
    agent any
    stages {
        stage('Build front') {
            steps {
                script {
                     front = docker.build(
                        "jaimesalas/e2e", 
                        "--pull -f $WORKSPACE/06_declarative_pipelines_e2e/04_e2e_jenkinsfile/front/Dockerfile.e2e $WORKSPACE/06_declarative_pipelines_e2e/04_e2e_jenkinsfile/front"
                        )
                }
            }
        }
        stage('Build back') {
            steps {
                script {
                    back = docker.build(
                        "jaimesalas/e2e-back",
                        "--pull -f $WORKSPACE/06_declarative_pipelines_e2e/04_e2e_jenkinsfile/back/Dockerfile $WORKSPACE/06_declarative_pipelines_e2e/04_e2e_jenkinsfile/back"
                    )
                }
            }
        }
        stage('e2e') {
            steps {
                script {
                    withockerNetwork{n ->
                        back.withRun("--name e2e-back --network ${n} -e PORT=4000") {c ->
                            docker.script.sh(
                                script: "docker run --rm -e API_URL=http://e2e-back:4000 --network ${n} jaimesalas/e2e npm run test:e2e",
                                returnStdout: false
                            )
                        }
                    }
                }
            }
        }
    }
}
```

For a not nested solution, the groovy file look like this

```groovy
def front
def back 

def withDockerNetwork(Closure inner) {
  try {
    networkId = UUID.randomUUID().toString()
    sh "docker network create ${networkId}"
    inner.call(networkId)
  } finally {
    sh "docker network rm ${networkId}"
  }
}

pipeline {
    agent any
    stages {
        stage('Build front') {
            steps {
                script {
                    front = docker.build("jaimesalas/e2e", "--pull -f ./front/Dockerfile.e2e ./front")
                }
            }
        }
        stage('Build back') {
            steps {
                script {
                    back = docker.build("jaimesalas/e2e-back", "--pull -f ./back/Dockerfile ./back")
                }
            }
        }
        stage ('e2e') {
            steps {
                script {
                    withDockerNetwork{n ->
                        back.withRun("--name e2e-back --network ${n} -e PORT=4000") {c ->
                            docker.script.sh(
                                script: "docker run --rm -e API_URL=http://e2e-back:4000 --network ${n} jaimesalas/e2e npm run test:e2e", 
                                returnStdout: false
                            )
                        }
                    }
                }
            }
        }
    }
}
```

Create pipeline on CI server


