# Demo 1

Clean code - refactoring pipelines.

## Pre-reqs

Remove previous pipelines

Run Jenkins in [Docker](https://www.docker.com/products/docker-desktop):

```bash
./start_jenkins.sh <jenkins-image> <jenkins-volume-certs> <jenkins-volume-data>
```

Create a new directory _05_declarative_pipelines/src_tmp/jenkins-demos-review/01_.

- Execute the following actions:
  - Create `01/demo1/1.1/Jenkinsfile`
  - Copy `solution` into `01`

Publish the code into GitHub:

```bash
git add .
git commit -m "added example code"
git push
```

Update `01/demo1/1.1/Jenkinsfile` with the following content:

```groovy
pipeline {
    agent any
    environment {
        VERSION = sh([ script: 'cd ./01/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
                sh '''
                    git version
                    docker version
                    node --version
                    npm version
                '''
            }
        }
        stage('Build') {
            steps {
                dir('./01/solution') {
                    echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
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
    }
}
```

Push the changes to the remote repository

```bash
git add .
git commit -m "added Jenkinsfile"
git push
```

## 1.1 A real build pipeline

Log into Jenkins at http://localhost:8080 with `lemoncode`/`lemoncode`.

- New item, pipeline, `demo1-1`
- Select pipeline from source control
- Git - https://github.com/JaimeSalas/jenkins-pipeline-demos.git
- Path to Jenkinsfile - `01/demo1/1.1/Jenkinsfile`
- Open in Blue Ocean
- Run

> Walk through the [Jenkinsfile](./1.1/Jenkinsfile)

```groovy
stage('Audit tools') {
    steps {
        sh '''
            git version
            docker version
            node --version
            npm version
        '''
    }
}
```

Here we are checking the tool versioning.

```groovy
stage('Build') {
    steps {
        dir('./01/solution') {
            echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
            sh '''
                npm install
                npm run build
            '''
        }
    }
}
```

Here we're simply doing the build

With `dir` we change the directory. Then we run the related unit tests: 

```groovy
stage('Unit Test') {
    steps {
        dir('./01/solution') {
            sh 'npm test'
        }
    }
}
```

We want that this Jenkinsfile be useful for more than one scenrio, right now is only good for continous integration, what we want is to include a manual way to trigger this build and set that is a release candidate.

## 1.2 Adding parameters for RC build

Create `01/demo1/1.2/Jenkinsfile`

```groovy
pipeline {
    agent any
    /*diff*/
    parameters {
        booleanParam(name: 'RC', defaultValue: false, description: 'Is This a Release Candidate?')
    }
    /*diff*/
    environment {
        VERSION = sh([ script: 'cd ./01/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
                sh '''
                    git version
                    docker version
                    node --version
                    npm version
                '''
            }
        }
        stage('Build') {
            /*diff*/
            environment {
                VERSION_SUFFIX = sh(script:'if [ "${RC}" == "true" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)
            }
            /*diff*/
            steps {
                dir('./01/solution') {
                    // echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
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

Push changes to remote repository

```bash
git add .
git commit -m "added Jenkinsfile with RC"
git push
```

- Copy item, `demo1-2` from `demo1-1`
- Path to Jenkinsfile `01/demo1/1.2/Jenkinsfile`
- Open in Blue Ocean
- Run (first build doesn't show option)

> Walk through the [Jenkinsfile](./1.2/Jenkinsfile)

```groovy
parameters {
    booleanParam(name: 'RC', defaultValue: false, description: 'Is This a Release Candidate?')
}
```

This way we can add conditions to the build, when a build is trigger will prompt a message box for the user. Now that we want is control the `version suffix` depending on that is or not a RC

```diff
stage('Build') {
+   environment {
+       VERSION_SUFFIX = "${sh(script:'if [ "${RC}" == "false" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)}"
+   }
    steps {
        dir('./01/solution') {
-           echo "Building version ${VERSION} with suffix: ${VERSION_RC}"
+           echo "Building version ${VERSION} with suffix: ${VERSION_SUFFIX}"
            sh '''
                npm install
                npm run build
            '''
        }
    }
}
```

```groovy
VERSION_SUFFIX = "${sh(script:'if [ "${RC}" == "false" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)}"
```

If is not a release candidate we add the build number, if is a release candidate we add just the version RC. Modify the pipeline as follows:

```groovy
// ....
stage('Unit Test') {
    steps {
        dir('./01/solution') {
            sh 'npm test'
        }
    }
}
/*diff*/
stage('Publish') {
    when {
        expression { return params.RC }
    }
    steps {
        archiveArtifacts('01/solution/app/')
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
        booleanParam(name: 'RC', defaultValue: false, description: 'Is This a Release Candidate?')
    }
    environment {
        VERSION = sh([ script: 'cd ./01/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
        VERSION_RC = "rc.2"
    }
    stages {
        stage('Audit tools') {
            steps {
-               sh '''
-                   git version
-                   docker version
-                   node --version
-                   npm version
-               '''
+               auditTools()
            }
        }
        stage('Build') {
            environment {
-               VERSION_SUFFIX = sh(script:'if [ "${RC}" == "true" ] ; then echo -n "${VERSION_RC}+ci.${BUILD_NUMBER}"; else echo -n "${VERSION_RC}"; fi', returnStdout: true)
+               VERSION_SUFFIX = getVersionSuffix()
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
+
+String getVersionSuffix() {
+   if (params.RC) {
+       return env.VERSION_RC
+   } else {
+       return env.VERSION_RC + 'ci' + env.BUILD_NUMBER
+   }
+}
+
+void auditTools() {
+    sh '''
+        git version
+        docker version
+        node --version
+        npm version
+    '''
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
        booleanParam(name: 'RC', defaultValue: false, description: 'Is This a Release Candidate?')
    }
    environment {
        VERSION = sh([ script: 'cd ./01/solution && npx -c \'echo $npm_package_version\'', returnStdout: true ]).trim()
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
                VERSION_SUFFIX = getVersionSuffix()
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

String getVersionSuffix() {
    if (params.RC) {
        return env.VERSION_RC
    } else {
        return env.VERSION_RC + 'ci' + env.BUILD_NUMBER
    }
}

void auditTools() {
    sh '''
        git version
        docker version
        node --version
        npm version
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
