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
library identifier: 'jenkins-library-review@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/JaimeSalas/jenkins-library-review.git'])


pipeline {
    agent any
    parameters {
        booleanParam(name: 'RC', defaultValue: false, description: 'Is this a Release Candidate?')
    }
    environment {
        VERSION = "0.1.0"
        VERSION_RC = "rc.2"
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
                echo "Building version ${VERSION} with suffix: ${VERSION_SUFFIX}"
                sh 'dotnet build -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_SUFFIX}" ./01/src/Pi.Web/Pi.Web.csproj'
            }
        }
        stage('Unit Test') {
            steps {
                dir('./01/src') {
                    sh '''
                        dotnet test --logger "trx;LogFileName=Pi.Math.trx" Pi.Math.Tests/Pi.Math.Tests.csproj
                        dotnet test --logger "trx;LogFileName=Pi.Runtime.trx" Pi.Runtime.Tests/Pi.Runtime.Tests.csproj
                    '''
                    mstest testResultsFile:"**/*.trx", keepLongStdio: true
                }
            }
        }
        stage('Smoke Test') {
            steps {
                sh 'dotnet ./01/src/Pi.Web/bin/Debug/netcoreapp3.1/Pi.Web.dll'
            }
        }
        stage('Publish') {
            when {
                expression { return params.RC }
            }
            steps {
                sh 'dotnet publish -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_RC}" ./01/src/Pi.Web/Pi.Web.csproj -o ./out'
                archiveArtifacts('out/')
            }
        }
    }
}
```

Jenkins API for validating pipeline syntax

Move on  terminal to the folder that contains the Jenkinsfile that we want to `lint`, in this case [Jenkinsfile](jenkins-pipeline-demos/01/demo3/). This does not check that the pipeline 'compiles', just checks the syntax. There's an extension for VSCode, `Jenkins Pipeline Linter Conector`.

> Reference: https://sandrocirulli.net/how-to-validate-a-jenkinsfile/

```
curl --user lemoncode:lemoncode -X POST -F "jenkinsfile=<./Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate
```
If we introduce an error we get

```bash
Jaimes-MacBook-Pro:demo3 jaimesalaszancada$ curl --user lemoncode:lemoncode -X POST -F "jenkinsfile=<./Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate
Errors encountered validating Jenkinsfile:
WorkflowScript: 10: expecting ''', found '\n' @ line 10, column 34.
           VERSION = '0.1.0" 
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

