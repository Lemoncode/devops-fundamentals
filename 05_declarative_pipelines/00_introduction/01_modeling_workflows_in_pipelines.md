# Modelling workflows in pipelines

## 1.1 A multi-stage pipeline

* Create a new Jenkinsfile on `demo1/1.1/Jenkinsfile`

```groovy
pipeline {
    agent any 
    environment {
        RELEASE='0.0.1'
    }
    stages {
        stage('Build') {
            agent any
            environment {
                LOG_LEVEL='INFO'
            }
            steps {
                echo "Building release ${RELEASE} with log level ${LOG_LEVEL}..."
            }
        }
        stage('Test') {
            steps {
                echo "Testing. I can see release ${RELEASE}, but not log level ${LOG_LEVEL}"
            }
        }
    }
}
```

```bash
git add .
git commit -m "added demo1/1.1"
git push
```


Log into Jenkins at http://localhost:8080 with `lemoncode`/`lemoncode`.

- New item, pipeline, `demo1-1.1`
- Select pipeline from source control
- Git - https://github.com/JaimeSalas/jenkins-pipeline-demos.git
- Branch `main`
- Path to Jenkinsfile `demo1/1.1/Jenkinsfile`

> Walk through the [Jenkinsfile](./1.1/Jenkinsfile)

- Run and check 
- Fails because step in second stage uses unknown variable `LOG_LEVEL`

```
[Checks API] No suitable checks publisher found.
groovy.lang.MissingPropertyException: No such property: LOG_LEVEL for class: groovy.lang.Binding
	at groovy.lang.Binding.getVariable(Binding.java:63)
```

## 1.2 Requesting user input

* Create a new Jenkinsfile on `demo1/1.2/Jenkinsfile`

```groovy
pipeline {
    agent any
    environment {
        RELEASE='0.0.1'
    }
    stages {
        stage('Build') {
            agent any
            environment {
                LOG_LEVEL='INFO'
            }
            steps {
                echo "Building release ${RELEASE} with log level ${LOG_LEVEL}..."
            }
        }
        stage('Test') {
            steps {
                echo "Testing release ${RELEASE}..."
            }
        }
        stage('Deploy') {
            input {
                message 'Deploy?'
                ok 'Do it!'
                parameters {
                    string(name: 'TARGET_ENVIRONMENT', defaultValue: 'PROD', description: 'Target deployment environment')
                }
            }
            steps {
                echo "Deploying release ${RELEASE} to environment ${TARGET_ENVIRONMENT}"
            }
        }
    }
    post {
        always {
            echo 'Prints wether deploy happened or not, success or failure'
        }
    }
}
```

Back to http://localhost:8080

- Copy item, `demo1-1.1` from `demo1-1.2`
- Path to Jenkinsfile `demo1/1.2/Jenkinsfile`

> Walk through the [Jenkinsfile](./1.2/Jenkinsfile)

```
    input {
        message 'Deploy?'
        ok 'Do it!'
        parameters {
            string(name: 'TARGET_ENVIRONMENT', defaultValue: 'PROD', description: 'Target deployment environment')
        }
    }
    steps {
        echo "Deploying release ${RELEASE} to environment ${TARGET_ENVIRONMENT}"
    }
```

This step will request an input from the user. Notice that in following stage steps, we can access *TARGET_ENVIRONMENT*. If we choose _abort_ the following steps are not done.

```
post {
    always {
        echo 'Prints wether deploy happened or not, success or failure'
    }
}
```

On _post_ command we can have different conditions here we're using _always_

- Run and check
- Open console from running build
- Pauses on input stage - OK or abort
- Post runs every time

## 1.3 Parallel stages

* Create a new Jenkinsfil on `demo1/1.3/Jenkinsfile`

```groovy
pipeline {
    agent any
    environment {
        RELEASE='0.0.1'
    }
    stages {
        stage('Build') {
            environment {
                LOG_LEVEL='INFO'
            }
            parallel {
                stage('linux-arm64') {
                    steps {
                        echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
                    }
                }
                stage('linux-amd64') {
                    steps {
                        echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
                    }
                }
                stage('windows-amd64') {
                    steps {
                        echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
                    }
                }
            }
        }
        stage('Test') {
            steps {
                echo "Testing release ${RELEASE}..."
            }
        }
        stage('Deploy') {
            input {
                message 'Deploy?'
                ok 'Do it!'
                parameters {
                    string(name: 'TARGET_ENVIRONMENT', defaultValue: 'PROD', description: 'Target deployment environment')
                }
            }
            steps {
                echo "Deploying release ${RELEASE} to environment ${TARGET_ENVIRONMENT}"
            }
        }
    }
    post {
        always {
            echo 'Prints wether deploy happened or not, success or failure'
        }
    }
}
```

Back to http://localhost:8080

- Copy item, `demo1-1.3` from `demo1-1.2`
- Path to Jenkinsfile `demo1/1.3/Jenkinsfile`

> Walk through the [Jenkinsfile](./1.3/Jenkinsfile)

```
parallel {
    stage('linux-arm64') {
        steps {
            echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
        }
    }
    stage('linux-amd64') {
        steps {
            echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
        }
    }
    stage('windows-amd64') {
        steps {
            echo "Building release ${RELEASE} for ${STAGE_NAME} with log level ${LOG_LEVEL}..."
        }
    }
}
```

With the _parallel_ we can run multiple stages on parallel.


- Run and check
- Parallel stages complete in any order
- Then pause on input and then post