# Add Canary Stage

In this demo we're going to create a new stage for the Canary Deployment. 

## Production Branch

Our Canary deployment are going to be done from a new branch `production`. The idea is that we're going to merge from `master/main` to production. And it's here where we're going to do the `canary deployment`.

```bash
git checkout -b production
git push -u origin production
```

Update `Jenkinsfile` to include a new step canary step

```groovy
pipeline {
    agent any 
    /*diff*/
    parameters {
        booleanParam(name: 'CANARY_DEPLOYMENT', defaultValue: false, description: 'Deploy Canary?')
    }
    /*diff*/
    environment {
        imageName = 'jaimesalas/math-api'
        ec2Instance = 'ec2-15-236-142-40.eu-west-3.compute.amazonaws.com'
        appPort = 80
    }
    stages {
        stage('Install dependencies') {
            agent {
                docker {
                    image 'node:14-alpine'
                    reuseNode true
                }
            }
            steps {
                sh 'npm ci'
            }
        }
        stage('Tests') {
            agent {
                docker {
                    image 'node:14-alpine'
                    reuseNode true
                }
            }
            steps {
                sh 'npm test'
            }
        }
        stage('Staging Tests') {
            when {
                branch 'staging'
            }
            agent {
                docker {
                    image 'node:14-alpine'
                    reuseNode true
                }
            }
            environment {
                BASE_API_URL = "http://$ec2Instance:$appPort"
            }
            steps {
                sh 'npm run test:e2e'
            }
        }
        stage('Build image & push it to DockerHub') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    def dockerImage = docker.build(imageName + ':latest')
                    withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                        dockerImage.push()
                        sh 'docker rmi $imageName'
                    }
                }
            }
        }
        stage('Deploy to server') {
            when {
                branch 'develop'
            }
            environment {
                containerName = 'math-api'
            }
            steps {
                withCredentials(
                bindings: [sshUserPrivateKey(
                    credentialsId: 'ec2-ssh-credentials',
                    keyFileVariable: 'identityFile',
                    passphraseVariable: 'passphrase',
                    usernameVariable: 'user'
                )
                ]) {
                script {
                    sh '''
                        ssh -o StrictHostKeyChecking=no -i $identityFile $user@$ec2Instance \
                        APP_PORT=$appPort CONTAINER_NAME=$containerName IMAGE_NAME=$imageName bash < ./scripts/deploy.sh
                    '''
                    }
                }
            }
        }
        /*diff*/
        stage('Canary Deploy') {
          when {
            branch 'production'
          }
          steps {
            script {
              if (params.CANARY_DEPLOYMENT) {
                versioningLatestAndPushImage(imageName, 'v2')
                cleanLocalImages(imageName, 'v2')
                
                sh 'echo connect to kubernetes and apply canary deplyement...'
              } else {
                versioningLatestAndPushImage(imageName, 'v1')
                cleanLocalImages(imageName, 'v1')
              }
            }
          }
        }
        /*diff*/
    }
}
/*diff*/
void versioningLatestAndPushImage(String imageName, String version) {
  withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
      echo "pull latest"
      sh "docker pull ${imageName}:latest"
      sh "echo tagging to ${version}"
      sh "docker tag ${imageName}:latest ${imageName}:${version}"
      sh "echo pushing ${imageName}:${version}"
      sh "docker push ${imageName}:${version}"
  }
} 

void cleanLocalImages(String imageName, String version) {
  echo 'removing local images'
  sh "docker rmi ${imageName}:latest"
  sh "docker rmi ${imageName}:${version}"
}
/*diff*/
```

1. We have added a new variable `CANARY_DEPLOYMENT`, to make this value truthy, the user must start the pipeline and set the value.
2. The canary stage only runs if the branch is production.
3. We have done a little refactor to make the code cleaner.