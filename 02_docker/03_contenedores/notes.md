## Contenedores de Docker

### Ejecutando contenedores

```bash
$ docker run [OPT] IMAGE[:TAG|@DIGEST] [CMD] [ARG...]
```

[docker run reference](https://docs.docker.com/engine/reference/run/)

```bash
$ docker run myapp
```

El comando anterior ejecuta el contenedor, se ejecuta de manera aislada y parece que no ha ocurrido nada, sabemos que nuestra aplicación estaba expuesta en el puerto `8080`, pero si visitamos `localhost:8080`, no ocurre nada.

```bash
$ docker run -p 8080:8080 myapp
```

Estamos realizando mapeo de puertos con el flag *-p*.

Podemos ejecutar los contenedores en un modo interactivo, `stdin`, `stdout` y `stderr` son redirigidos al `host`.

```bash
$ docker run -it fedora bash

$ cat /etc/*-release
```

```bash
$ docker run -it fedora python3

>>> import os
>>> os.system("cat /etc/*-release")
```

> Para selir del terminal de Python: `ctrl + D` 

Podemos, ejecutar nuestros contenedores en modo `detach`

```bash
$ docker run -d -p 8080:8080 --name myapp myapp
```

### Comprobando Contenedores

Podemos listar los contenedores que se están ejecutando en nuestro sistema

```bash
$ docker ps
```

Para inspeccionar un contenedor en ejecución

```bash
$ docker inspect myapp
```

Para obtener los logs de un contenedor:

```bash
$ docker logs myapp
```

```bash
$ docker logs -f myapp
```

*-f* flag, hace que los _logs_ trabajen en _flow mode_, haciendo que se vuelquen en el _stdout_ del contenedor. 

### Stop / Kill Contenedores en Ejecución

```bash
docker stop <container id or name>
```

```bash
docker kill <container id or name>
```

> https://superuser.com/questions/756999/whats-the-difference-between-docker-stop-and-docker-kill

_stop_ intenta un apagado agraciado lanzando la señal `SIGTERM`, mientras que _kill_ simplemente mata el procesa por defecto y además permite enviar otras señales

### Start / Restart Contenedores

```bash
$ docker start myapp
```

```bash
$ docker restart myapp
```

> https://stackoverflow.com/questions/40372321/whats-the-difference-between-docker-start-and-docker-restart#:~:text=The%20docker%20restart%20command%20will,more%20robust%20in%20this%20situation.

### Eliminar contenedores

```bash
$ docker rm <container id or name>
```

Podemos hacer que un contenedor se auto elimine is está `stopped` o `killed`.

```bash
$ docker run -d --rm -p 8080:8080 --name myapp myapp
```

### Ejecutar Comandos dentro de un Contenedor en Ejecución

```bash
$ docker exec -it <container name or id> <command>
```

### ENV Variables 

Vamos a ver como trabajan las variables de entorno.

[Demo 00_ENV_variables](03_docker_containers/00_ENV_variables)


### CMD vs ENTRYPOINT

[Demmo 00_understanding_run_cmd_entrypoint](02_docker/01_images/00_understanding_run_cmd_entrypoint)

> Ejercicio: Explicar en detalle después de la demo anterior que es lo que está ocurriendo aquí

```bash
$ docker run -p 8080:8080 myapp bash
```

```Dockerfile
FROM node:12-stretch

WORKDIR /opt/app

COPY . .

RUN npm install --only=production

EXPOSE 8080

CMD [ "npm", "start" ]
```

### Docker Top

[top reference](https://docs.docker.com/engine/reference/commandline/top/)

```bash
$ docker top myapp
```

### Memory Limits

```bash
$ docker run -d --rm -m=100m -p 8080:8080 --name myapp myapp
```

```bash
$ docker inspect myapp
```

### CPU Limits

```bash
$ docker run -d --rm -p 8080:8080 --cpus=1 --name myapp myapp
```

```bash
$ docker inspect myapp
```

¿Qué ocurrira si le intentamos dar más cpus que las que tiene el sistema actual?

```bash
$ docker run -d --rm -p 8080:8080 --cpus=20 --name myapp myapp
```

### Other Dockerfile Locations

[Demo other Dockerfile locations](03_contenedores/01_otras_localizaciones_dockerfile)

### Restart

* No (default)
* On Failure (max times)
* Unless Stopped
* Always

```bash
$ docker run -d --restart=always --name myapp myapp
$ sudo systemctl restart docker
```

### Builder Pattern

> NOTE: Review https://docs.docker.com/develop/develop-images/multistage-build/
> https://codefresh.io/docker-tutorial/node_docker_multistage/

[Demo Builder Pattern](03_contenedores/02_builder_pattern)