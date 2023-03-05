# Demo 2

Writing and using shared libraries `https://github.com/JaimeSalas/jenkins-pipeline-demo-library`.

Create a new GitHub repo, clone on local, and create the following _directory/file_ on root `./vars/auditTools.groovy`

```groovy
def call() { // 2
    node { // 1
        sh '''
            git version
            docker version
            node --version
            npm version
        '''
    }
}
```

- To make it availabe as a part of a shared library we have to do three things
  1. The code must be wrap into a _node_ block, wich just made it available as a pipeline step in my declarative pipeline.
  2. The name of the method has to be _call_. That's the default name that _Jenkins_ specs when it invokes one of the custom steps.
  3. The name of the script `auditTools.groovy` is the name that we want to use for my custom step.

Push changes

## Pre-reqs

Run Jenkins in [Docker](https://www.docker.com/products/docker-desktop):

```bash
$ ./start_jenkins.sh <jenkins-image> <jenkins-volume-certs> <jenkins-volume-data>
```

## 2.1 Using a shared library

Create a new git repository `jenkins-pipeline-demo-library`

- Reminder - `auditTools` function from [1.3 Jenkinsfile](../demo1/1.3/Jenkinsfile)
- Moved shared library in [auditTools.groovy](../shared-library/vars/auditTools.groovy)
- Published to https://github.com/JaimeSalas/jenkins-pipeline-demo-library

We have moved the code from audit tools to its own script file.

Notice that all the script files are in the same directory called _vars_, and that's another requirement. So in order to find these custom steps that are part of my libary they have to be in this folder.

> Used in [2.1 Jenkinsfile](./01/demo2/2.1/Jenkinsfile)

- Create `01/demo2/2.1/Jenkinsfile`.

> We must point to the right jenkins libary repository

```groovy
library identifier: 'jenkins-pipeline-demo-library@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/JaimeSalas/jenkins-pipeline-demo-library']) // [1]

pipeline {
    agent any
    stages {
        stage('Audit tools') {
            steps {
                auditTools() // [2]
            }
        }
    }
}
```

1. This is how the pipeline references the libary. The first part is the _identifier_, this is the project name and the branch of source code in GitHub. Then Jenkins has to know how to fetch the library and that is what this _retriever_ block does.

2. To run it we just need to use the script name.

- Copy item, `demo2-1` from `demo1-1`
- Path to Jenkinsfile `01/demo2/2.1/Jenkinsfile`
- Open in Blue Ocean
- Run
- Check pipeline log - fetches library

## 2.2 Failures in shared pipelines

> Create auditTools2.groovy on library repo

```groovy
def call(Map config) {
    node {
        echo ${config.message}
        sh '''
            git version
            docker version
            node --version
            npm version
        '''
    }
}
```

One thing to bear on mind is the versioning, that could be dangerous.

- Copy item, `demo2-2` from `demo2-1`
- Path to Jenkinsfile `01/demo2/2.2/Jenkinsfile`
- Open in Blue Ocean
- Run - fails
- Check pipeline log

> Walk through the [2.2 Jenkinsfile](./01/demo2/2.2/Jenkinsfile)

```groovy
library identifier: 'jenkins-pipeline-demo-library@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/JaimeSalas/jenkins-pipeline-demo-library'])

pipeline {
    agent any
    stages {
        stage('Audit tools') {
            steps {
                auditTools2 message: 'This is demo 2' // The reason because is not working it's because echoing a message need double quotes
            }
        }
    }
}
```

- Check library method [auditTools2.groovy](../shared-library/vars/auditTools2.groovy)
- Fix quotes & push GitHub repo > `echo "${config.message}"`
- Build again - passes, no change to code or pipeline

## 2.3 Shared libraries in a full build

> Create getVersionSuffix.groovy on library repo

```groovy
def call(Map config) { // [1]
    node {
        if (config.isReleaseCandidate) { // [2]
            return config.rcNumber // [3]
        } else {
            return config.rcNumber + '+ci' + env.BUILD_NUMBER
        }
    }
}
```

The way that this script is called

```groovy
VERSION_SUFFIX = getVersionSuffix rcNumber: env.VERSION_RC, isReleaseCandidate: params.RC
```

1. The way that paramenters work is that the method takes this map object called _config_ that can have lots of key value pairs
2. And inside that is looking for key called _isReleaseCandidate_, this is a boolean value that the pipeline will feed.
3. Also expects the key _rcNumber_

Create `01/demo2/2.3/Jenkinsfile`, starting from `01/demo1/1.3/Jenkinsfile`

```groovy
/*diff*/
library identifier: 'pipeline-utils@main',
        retriever: modernSCM([$class: 'GitSCMSource', remote: 'https://github.com/JaimeSalas/pipeline-utils.git'])
/*diff*/

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
                /*diff*/
                VERSION_SUFFIX = getVersionSuffix rcNumber: env.VERSION_RC, isReleaseCandidate: params.RC
                /*diff*/
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

- Compare 1.3 Jenkinsfile and [2.3 Jenkinsfile](./01/demo2/2.3/Jenkinsfile)
- Copy item, `demo2-3` from `demo2-1`
- Path to Jenkinsfile `01/demo2/2.3/Jenkinsfile`
- Build now
- Run

> Alternative - folder and global libraries

- New item, folder, `01`
- Expand _Pipeline libraries_; implicit load but untrusted

- _Manage Jenkins_ ... _Configure System_
- Expand _Global Pipeline libraries_; implicit load and trusted
