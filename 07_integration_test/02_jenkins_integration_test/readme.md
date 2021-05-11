# Jenkins Integration Test


## Basic branch flow

* Create a pipeline that audits the tools
* The pipeline will run simple tests - No dependencies here

```groovy
pipeline {
    agent any
    stages {
        stage('audit tools') {
            steps {
                sh '''
                    docker -v
                    docker-compose -v
                '''
            }
        }
        stage('unit test') {
            agent any
            steps {
                echo 'run unit tests using Docker container base image'                
            }
        }
        stage('integration test') {
            steps {
                echo 'run integartion tests with Docker compose'
            }
        }
    }
    post {
        always {
            echo 'clean resources'
        }
    }
}
```

Let's update this branch and try to run the unit tests

```diff
stage('unit test') {
    steps {
        echo 'run unit tests using Docker container base image'  
+       sh 'npm install'              
+       sh 'npm test'
    }
}
```

## Running integrations tests

* Now it's time to use Docker compose in order to run integration tests

```groovy
pipeline {
    agent any
    stages {
        stage('audit tools') {
            steps {
                sh '''
                    docker -v
                    docker-compose -v
                '''
            }
        }
        stage('unit test') {
            steps {
                sh 'npm install'             
                sh 'npm test'
            }
        }
        stage('integration test') {
            steps {
                echo 'run integration tests with Docker compose'
                /*diff*/
                sh 'docker-compose -f test-integration.yml up -d'
                script {
                    def status = sh(script: 'docker wait test-integration', returnStdout: true)
                    println status
                }
                /*diff*/
            }
        }
    }
    post {
        always {
            echo 'clean resources'
            /*diff*/
            sh 'docker-compose -f test-integration.yml down --rmi all -v'
            /*diff*/
            cleanWs()
        }
    }
}
```

If  we run our tests we find out that `status` is equal **zero**. That's mean that our integration tests are working, cool. Let's break them.

```diff
describe('game.dal', () => {
  describe('getGames', () => {
    test('returns the games related to a player', async () => {
      // Arrange
      await Promise.all([insertPlayer('joe', 1), insertWord(1, 'car', 'vehicles')]);
      await insertGame(1, 1, 'not_started');
      const gameDAL = gameDALFactory(knex);

      // Act
      const [game] = await gameDAL.getGames(1);
      const { player_id, word_id, game_state } = game;

      // Assert
-     expect(player_id).toEqual(1);
+     expect(player_id).toEqual(2);
      expect(word_id).toEqual(1);
      expect(game_state).toEqual('not_started');
    });
  });
});
```

Run the pipeline again. Oops! Although we have a different code (not zero) the pipeline is exists successfuly, let's fix this situation:

```diff
# ...
stage('integration test') {
    steps {
        echo 'run integration tests with Docker compose'
        sh 'docker-compose -f test-integration.yml up -d'
        script {
            def status = sh(script: 'docker wait test-integration', returnStdout: true)
-           println status
+           def statusInt = status.toInteger() 
+                   
+           if (statusInt != 0) {
+               throw new Exception(
+                   "Integration tests failed you can debug complete output by removing d flag on docker-compose"
+               )
+           }
        }
    }
}
# ...
```

Run the pipeline again and check that is broken. Now for last change the tests again:

```diff
describe('game.dal', () => {
  describe('getGames', () => {
    test('returns the games related to a player', async () => {
      // Arrange
      await Promise.all([insertPlayer('joe', 1), insertWord(1, 'car', 'vehicles')]);
      await insertGame(1, 1, 'not_started');
      const gameDAL = gameDALFactory(knex);

      // Act
      const [game] = await gameDAL.getGames(1);
      const { player_id, word_id, game_state } = game;

      // Assert
-     expect(player_id).toEqual(2);
+     expect(player_id).toEqual(1);
      expect(word_id).toEqual(1);
      expect(game_state).toEqual('not_started');
    });
  });
});
```

And run the pipeline for last to ensure that is working properly.