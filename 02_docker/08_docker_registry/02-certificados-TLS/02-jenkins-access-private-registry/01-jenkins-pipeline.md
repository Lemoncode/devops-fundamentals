# Jenkins Pipeline

Una vez configurada la connectividad entre los disttinto actores podemos proceder a crear la pipeline de Jenkins

## Configurando Jenkins y pipeline

Jenkins está expuesto en el puerto 8080 de nuestra máquina local. Podemos acceder a él en el navegador mediante [http://localhost:8080]. Vamos a necesitar la clave iniciar de Jenkins. Para ello nos conectaremos a la máquina de Jenkins y ejecutaremos:

```bash
$ vagrant ssh jenkins
vagrant@jenkins:~$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword
2db29cc56c3a45beacf9165d98119803
```

Utilizamos en el navegador la contraseña del fichero y continuamos con `Install suggested plugins`. Pasamos a la siguiente pantalla donde nos pedirá crear un usuario y contraseña. Continuamos y dejamos la URL de Jenkins a [http://localhost:8080]. 

No es muy relevante para la demo. Una vez tengamos la interfaz de Jenkins disponible nos dirigiremos a:

1. `Manage Jenkins` → `Manage Plugins` a la pestaña Available y buscaremos "docker" en la barra de búsqueda para seleccionar los plugins `Docker` y `Docker Pipeline`. 

2. Pulsamos sobre el botón `Install without restart` y una vez se instalen marcamos la casilla `Restart Jenkins when installation is complete and no jobs are running`.

Una vez Jenkins se reinicie accedemos con el usuario y contraseña que creamos anteriormente y crearemos un nuevo proyecto haciendo click sobre `New Item`. Pondremos de nombre `test-private-registry` y crearemos el proyecto como tipo Pipeline. Una vez creado accedemos al proyecto haciendo click sobre su nombre en la tabla y hacemos click sobre `Configure`. En la sección Pipeline indicamos añadimos como script la siguiente pipeline:

```groovy
pipeline {
  agent any
  environment {
    // Importante que el nombre de la variable sea "DOCKER_REGISTRY_URL", de lo contrario
    // el tagging de la imagen fallará a la hora de hacer el push.
    DOCKER_REGISTRY_URL = 'https://registry.intranet'
    imageName = "custom-nginx"
    dockerImage = ''
  }
  stages {
    stage('Create Dockerfile') {
      steps {
        sh '''
        echo "FROM nginx:latest" > Dockerfile
        echo "RUN sed -i 's/Welcome to nginx/Welcome to custom nginx/' /usr/share/nginx/html/index.html" >> Dockerfile
        '''
      }
    }
    stage('Build docker image') {
      steps {
        script {
          dockerImage = docker.build(imageName)
        }
      }
    }
    stage('Deploy to registry') {
      steps {
        script {
          withDockerRegistry(credentialsId: 'registry-credentials', url: "$DOCKER_REGISTRY_URL") {
            dockerImage.push('latest')
          }
        }
      }
    }
    stage('Remove local images') {
      steps {
        script {
          // Removes image name
          sh "docker rmi ${dockerImage.id}"
          // Removes image full qualified name (<registry>/<image_name>)
          sh "docker rmi ${dockerImage.imageName()}"
          sh "docker logout $DOCKER_REGISTRY_URL"
        }
      }
    }
    stage('Pull image from registry') {
      agent {
        docker {
          image imageName
          registryUrl DOCKER_REGISTRY_URL
          registryCredentialsId 'registry-credentials'
        }
      }
      steps {
        sh 'nginx -V'
      }
    }
    stage('Again remove local images') {
      steps {
        script {
          // Removes image full qualified name (<registry>/<image_name>)
          sh "docker rmi ${dockerImage.imageName()}"
        }
      }
    }
  }
}
```

Esta pipeline hace uso de unas credenciales `registry-credentials` que debemos de crear. Guardamos cambios pulsando el botón `Save` y procederemos a crear las credenciales.

Nos dirigimos a `Manage Jenkins` → `Manage Credentials` → `Jenkins store` → `Global credentials` → `Add Credentials`. Añadiremos la siguiente información:

* Kind: `Username with password`

* Username: `devops`

* Password: `secretpassword`

* Id: `registry-credentials`

* Description: `Registry credentials`

Ya tenemos todo listo para ejecutar la pipeline. Volvemos al `Dashboard`, accedemos a nuestro proyecto y pulsamos en `Build Now`. Podremos ver el job #1 que se ejecutó de forma exitosa.

## Trouble shooting

A la hora de ejecutar la pipeline podemos encontrar que el usario de Jenkins, no tiene suficientes privilegios, [enlace relcionado](https://stackoverflow.com/questions/47854463/docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socke)

Una manera directa:

```bash
$ chmod 777 /var/run/docker.sock
```

