# e2e Jenkinsfile

For last we're going to create a pipeline, that makes the same work that the Docker engine does for us.

> Exercise: Build that pipeline

## Solution

On root folder create a new `Jenkinsfile`

```groovy
def front
def back

def withDockerNetwork(Closure inner) {
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
        stage('Build front image') {
            steps {
                script {
                    front = docker.build(
                        "jaimesalas/front",
                        "--pull -f $WORKSPACE/06_declarative_pipelines_e2e_refactor/04_e2e_jenkinsfile/front/Dockerfile $WORKSPACE/06_declarative_pipelines_e2e_refactor/04_e2e_jenkinsfile/front"
                    )
                }
            }
        }
        stage('Build back image') {
            steps {
                script {
                    back = docker.build(
                        "jaimesalas/back",
                        "--pull -f $WORKSPACE/06_declarative_pipelines_e2e_refactor/04_e2e_jenkinsfile/back/Dockerfile $WORKSPACE/06_declarative_pipelines_e2e_refactor/04_e2e_jenkinsfile/back"
                    )
                }
            }
        }
        stage('Build e2e image') {
            steps {
                script {
                    docker.build(
                        "jaimesalas/e2e",
                        "--pull -f $WORKSPACE/06_declarative_pipelines_e2e_refactor/04_e2e_jenkinsfile/e2e/Dockerfile $WORKSPACE/06_declarative_pipelines_e2e_refactor/04_e2e_jenkinsfile/e2e"
                    )
                }
            }
        }
        stage('e2e run') {
            steps {
                dir('06_declarative_pipelines_e2e_refactor/04_e2e_jenkinsfile/e2e') {
                    script {
                        withDockerNetwork{n->
                            back.withRun("--name e2e-back --network ${n} -e PORT=4000") {c ->
                                front.withRun("--name e2e-front --network ${n} -e API_URL=http://e2e-back:4000"){d ->
                                    def pwd = sh(
                                        script: 'pwd',
                                        returnStdout: true
                                    ).trim()
                                    sh '''
                                        docker run --rm --network '''+n+''' \
                                        -e CYPRESS_baseUrl=http://e2e-front:8081 \
                                        -e CYPRESS_api_url=http://e2e-back:4000/scores \
                                        -v '''+pwd+'''/cypress:/app/cypress -v '''+pwd+'''/cypress.config.js:/app/cypress.config.js jaimesalas/e2e npm run cypress:run
                                    '''
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
```
