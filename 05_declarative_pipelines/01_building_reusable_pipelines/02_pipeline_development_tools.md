# Demo 3

Development workflow for pipelines and shared libraries.

## Pre-reqs

Run Jenkins in [Docker](https://www.docker.com/products/docker-desktop):

```bash
$ ./start_jenkins.sh <jenkins-image> <jenkins-volume-certs> <jenkins-volume-data>
```

## 3.1 Jenkinsfile Linter

* Create `01/demo3/Jenkinsfile`

```groovy
library identifier: 'pipeline-utils@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/JaimeSalas/pipeline-utils.git'])

pipeline {
    agent any
    parameters {
        booleanParam(name: 'RC', defaultValue: false, description: 'Is This a Release Candidate?')
    }
    environment {
        VERSION = sh([ script: 'cd ./01/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
        VERSION_RC = 'rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
                auditTools()
            }
        }
        stage('Build') {
            environment {
                VERSION_SUFFIX = getVersionSuffix rcNumber: env.VERSION_RC, isReleaseCandidate: params.RC
            }
            steps {
                dir('./01/solution') {
                    echo "Building version ${VERSION} with suffix: ${VERSION_SUFFIX}"
                    sh '''
                        npm install
                        npm run build
                    '''
                }
            }
        }
        stage('Unit Test') {
            steps {
                dir('./01/solution') {
                    sh 'npm test'
                }
            }
        }
        stage('Publish') {
            when {
                expression { return params.RC }
            }
            steps {
                archiveArtifacts('01/solution/app/')
            }
        }
    }
}

```

Jenkins API for validating pipeline syntax

Move on  terminal to the folder that contains the Jenkinsfile that we want to `lint`, in this case [Jenkinsfile](jenkins-pipeline-demos/01/demo3/). This does not check that the pipeline 'compiles', just checks the syntax. There's an extension for VSCode, `Jenkins Pipeline Linter Conector`.

> Reference: https://sandrocirulli.net/how-to-validate-a-jenkinsfile/

```bash
curl --user lemoncode:lemoncode -X POST -F "jenkinsfile=<./Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate
```

If we introduce an error we get

```bash
Errors encountered validating Jenkinsfile:
WorkflowScript: 11: expecting ''', found '\n' @ line 11, column 28.
           VERSION_RC = 'rc.2"
                              ^ 
```

> Usually need a crumb for CRSF protection

- Catches syntax errors
- Try quote mismatch
- Missing brackets for call
- Doesn't catch missing methods

> VS Code linter integration

- _Extensions_ - search `Jenkinsfile`
- Select _Jenkins Pipeline Linter Connector_
- _F1_ in Jenkinsfile

## 3.2 Pipeline Replay & Restart

- Open `demo2-2` build 1
- _Restart from stage_ uses original lib
    * Uses exactly the same code and resources, this is useful for CI server connectivity issues.
- _Replay_ allows edit
    * This is useful if you want to repeat your build without changing your `Jenkinsfile` on source control. Obviously when we have fix any trouble that cause the failed we have to go back and change then the `Jenkinsfile`
- Edited replay scripts are preserved in restart

