# Demo 1

Clean code - refactoring pipelines.

## Pre-reqs

Remove previous pipelines

Run Jenkins in [Docker](https://www.docker.com/products/docker-desktop):

```bash
$ ./start_jenkins.sh <jenkins-image> <jenkins-volume-certs> <jenkins-volume-data>
```

Create a new directory *05_declarative_pipelines/src_tmp/jenkins-demos-review/01*. Unzip code from `05_declarative_pipelines` directory

```bash
$ unzip code.zip -d ./src_temp/jenkins-demos-review/01
```

Push the changes to the remote repository

Install `mstest` plugin

Create `01/demo1/1.1/Jenkinsfile`

```groovy
pipeline {
    agent any
    environment {
        VERSION = "0.1.0"
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
                sh '''
                    git version
                    docker version
                    dotnet --list-sdks
                    dotnet --list-runtimes
                '''
            }
        }
        stage('Build') {
            steps {
                echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
                sh 'dotnet build -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_RC}" ./01/src/Pi.Web/Pi.Web.csproj'
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
    }
}
```

Push the changes to the remote repository

## 1.1 A real build pipeline

Log into Jenkins at http://localhost:8080 with `lemoncode`/`lemoncode`.

- New item, pipeline, `demo1-1`
- Select pipeline from source control
- Git - https://github.com/JaimeSalas/jenkins-pipeline-demos.git
- Path to Jenkinsfile  - `01/demo1/1.1/Jenkinsfile`
- Open in Blue Ocean
- Run

> Walk through the [Jenkinsfile](./1.1/Jenkinsfile)

```groovy
stage('Audit tools') {
    steps {
        sh '''
            git version
            docker version
            dotnet --list-sdks
            dotnet --list-runtimes
        '''
    }
}
```

```groovy
sh 'dotnet build -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_RC}" ./m3/src/Pi.Web/Pi.Web.csproj'
```
Here we're simply doing the build

This stage enumerates all the tools and versions related with the build.

```groovy
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
```

With `dir` we change the directory. Then we run the related unit tests, and also we're using `mstest` that comes from a plug-in, it's going to collect all results from the test runs and make them available to Jnkins in a JUnit format.

```groovy
stage('Smoke Test') {
    steps {
        sh 'dotnet ./01/src/Pi.Web/bin/Debug/netcoreapp3.1/Pi.Web.dll'
    }
}
```

For last we're simply running a smoke test.

We want that this Jenkinsfile be useful for more than one scenrio, right now is only good for continous integration, what we want is to include a manual way to trigger this build and set that is a release candidate.

## 1.2 Adding parameters for RC build

Create `01/demo1/1.2/Jenkinsfile`

```groovy
pipeline {
    agent any
    /*diff*/
    parameters {
        booleanParam(name: 'RC', defaultValue: false, description: 'Is this a Release Candidate?')
    }
    /*diff*/
    environment {
        VERSION = "0.1.0"
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
                sh '''
                    git version
                    docker version
                    dotnet --list-sdks
                    dotnet --list-runtimes
                '''
            }
        }
        stage('Build') {
            environment {
                VERSION_SUFFIX = "${sh(script:'if [ "${RC}" == "false" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)}"
            }
            steps {
                echo "Building version: ${VERSION} with suffix: ${VERSION_SUFFIX}"
                sh 'dotnet build -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_SUFFIX}" ./m3/src/Pi.Web/Pi.Web.csproj'
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
                sh 'dotnet ./m3/src/Pi.Web/bin/Debug/netcoreapp3.1/Pi.Web.dll'
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

Push changes to remote repository

- Copy item, `demo1-2` from `demo1-1`
- Path to Jenkinsfile `01/demo1/1.2/Jenkinsfile`
- Open in Blue Ocean
- Run (first build doesn't show option)

> Walk through the [Jenkinsfile](./1.2/Jenkinsfile)

```groovy
parameters {
    booleanParam(name: 'RC', defaultValue: false, description: 'Is this a Release Candidate?')
}
```

This way we can add conditions to the build, when a build is trigger will prompt a message box for the user. Now that we want is control the `version suffix` depending on that is or not a RC

```diff
stage('Build') {
+   environment {
+       VERSION_SUFFIX = "${sh(script:'if [ "${RC}" == "false" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)}"
+   }
    steps {
-       echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
+       echo "Building version ${VERSION} with suffix: ${VERSION_SUFFIX}"
-       sh 'dotnet build -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_RC}" ./01/src/Pi.Web/Pi.Web.csproj'
+       sh 'dotnet build -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_SUFFIX}" ./01/src/Pi.Web/Pi.Web.csproj'
    }
}
```

```groovy
VERSION_SUFFIX = "${sh(script:'if [ "${RC}" == "false" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)}"
```

If is not a release candidate we add the build number, if is a release candidate we add just the version RC. Modify the pipeline as follows:

```groovy
// ....
stage('Smoke Test') {
    steps {
        sh 'dotnet ./01/src/Pi.Web/bin/Debug/netcoreapp3.1/Pi.Web.dll'
    }
}
/*diff*/
stage('Publish') {
    when {
        expression { return params.RC }
    }
    steps {
        sh 'dotnet publish -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_RC}" ./01/src/Pi.Web/Pi.Web.csproj -o ./out'
        archiveArtifacts('out/')
    }
}
/*diff*/
// ....
```

This is conditional stage, and only will run if `RC` parameter was set to true

- Run again - _RC = no_
- Run again - _RC = yes_

> Check logs and artifacts


## 1.3 Moving pipeline logic into Groovy methods

Create `01/demo1/1.3/Jenkinsfile` starting from the previous one, and edit as follows

Let's refactor to get the semantic version that we want.

```diff
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
-               sh '''
-                   git version
-                   docker version
-                   dotnet --list-sdks
-                   dotnet --list-runtimes
-               '''
+               auditTools()
            }
        }
        stage('Build') {
            environment {
-               VERSION_SUFFIX = "${sh(script:'if [ "${RC}" == "false" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)}"
+               VERSION_SUFFIX = getVersionSuffix()
            }
            steps {
                echo "Building version: ${VERSION} with suffix: ${VERSION_SUFFIX}"
                sh 'dotnet build -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_SUFFIX}" ./m3/src/Pi.Web/Pi.Web.csproj'
            }
        }
        stage('Unit Test') {
            steps {
                dir('./m3/src') {
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
                sh 'dotnet ./m3/src/Pi.Web/bin/Debug/netcoreapp3.1/Pi.Web.dll'
            }
        }
        stage('Publish') {
            when {
                expression { return params.RC }
            }
            steps {
                sh 'dotnet publish -p:VersionPrefix="${VERSION}" --version-suffix "${VERSION_RC}" ./m3/src/Pi.Web/Pi.Web.csproj -o ./out'
                archiveArtifacts('out/')
            }
        }
    }
}
+
+String getVersionSuffix() {
+   if (params.RC) {
+       return env.VERSION_RC
+   } else {
+       return env.VERSION_RC + '+ci' + env.BUILD_NUMBER
+   }
+}
+
+void auditTools() {
+   sh '''
+       git version
+       docker version
+       dotnet --list-sdks
+       dotnet --list-runtimes
+   '''
+}
+
```

Push changes

- Copy item, `demo1-3` from `demo1-1`
- Path to Jenkinsfile `01/demo1/1.3/Jenkinsfile`
- Build now
- Run

> Walk through the [Jenkinsfile](./1.3/Jenkinsfile)

```groovy
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
                getVersionSuffix()
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

String getVersionSuffix() {
    if (params.RC) {
        return env.VERSION_RC;
    } else {
        return env.VERSION_RC + '+ci' + env.BUILD_NUMBER;
    }
}

void auditTools() {
    sh '''
        git version
        docker version
        dotnet --list-sdks
        dotnet --list-runtimes
    '''
}
```

We have created a method to get the `version suffix` pretty much easier to understand than the previous shell script

```groovy
String getVersionSuffix() {
    if (params.RC) {
        return env.VERSION_RC
    } else {
        return env.VERSION_RC + '+ci' + env.BUILD_NUMBER
    }
}
```

The other refactor that we have done is a method that could be useful for other pipelines

```groovy
void auditTools() {
    sh '''
        git version
        docker version
        dotnet --list-sdks
        dotnet --list-runtimes
    '''
}
```


- Open in Blue Ocean
- Run again - _RC = no_
- Run again - _RC = yes_

> Check logs and artifacts