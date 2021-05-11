## Docker Images

> Una imagen de Docker es una plantilla de sólo lectura, con instrucciones para crear un contenedor de Docker.

## Docker Hub

El Docker registry por defecto. Para ejecutar un contenedor, necesitamos una imagen, Docker Hub expone imágenes públicas, las cuales utilizaremos para crear nuestras propias imágenes.

### Docker Pull

```bash
$ docker pull ubuntu
```

El comando anterior recuperará la imagen de Docker Hub, el `registry` por defecto.

### Docker images

```bash
$ docker images
```

```bash
$ docker image ls
```

Listamos las imágenes que tenemos en nuestro local.

### Dockerfile

El proceso de `build` es descrito por el **Dockerfile**

[dockerfile reference](https://docs.docker.com/engine/reference/builder/)

```Dockerfile
# Base image
FROM ubuntu:latest

# Defining environment variables
ENV LANGUAGE es_ES
ENV HTTP_PORT 80

# Chaning the work directory
WORKDIR /opt

# Copying files into the image
COPY example.txt .
ADD server.py .
ADD https://github.com/coder/repo/mix.exs .
RUN cargo build

# Exposing Ports
EXPOSE 5555 8989 ${HTTP_PORT}

# Command
CMD [ "python3", "server.py" ]
```

## Dockerfile builder commands

### FROM

* `FROM` inicializa un nuevo escenario de `build` y establece la `Base Image` para las siguientes instrucciones. Un `Dockerfile` para que sea válido debe _comenzar_ con la instrucción `FROM`, sólo pudiendo ser precedida por `ARG`.

* `FROM` puede aparecer múltiples veces dentro de un mismo `Dockerfile`, para crear múltiples imágenes o usar un `build stage` como dependencia de otro. Cada `FROM` limpia cualquier estado creado previo.

* Podemos nombrar los `build stages` añadiendo `AS name` a la instrucción `FROM`. El nombre puede ser usado en los siguientes `FROM` por ejemplo `COPY --from=<name>`


[FROM reference](https://docs.docker.com/engine/reference/builder/#from) 

```Dockerfile
FROM ubuntu:18.04
...
```

```Dockerfile
FROM node:6.17.0-stretch-slim
...
```


### RUN

[RUN reference](https://docs.docker.com/engine/reference/builder/#run)

* Tiene dos formatos:
    - `RUN <commad>` (shell form)
    - `RUN ["executable", "param1", "param2"]` (exec form)

La instrrucción `RUN` ejecutará cualquier comando en una nueva capa sobre la imagen actual. El resultado anterior será usado para el próximo paso en el `Dockerfile`. 

> Layering RUN instructions and generating commits conforms to the core concepts of Docker where commits are cheap and containers can be created from any point in an image’s history, much like source control.

La forma _exec_ permite ejecutar la shell sin tener que especificar el ejecutable de shell.

La shell por defecto para el formato shell, se puede cambiar con el comando `SHELL`. En este formato podemos usar `\` para continuar una instrucción en la siguiente línea. Por ejemplo:

```Dockerfile
RUN /bin/bash -c 'source $HOME/.bashrc; \
echo $HOME'
```

```Dockerfile
RUN apt-get update
RUN apt-get install npm -y
RUN cargo build
RUN MIX_ENV=prod mix release
```

### COPY    

[COPY reference](https://docs.docker.com/engine/reference/builder/#copy)

```Dockerfile
COPY app app/
COPY app /opt/app/
COPY test_* /home/tests
COPY --chown=777:group script.sh /scripts
```

### ADD

[ADD reference](https://docs.docker.com/engine/reference/builder/#add)

```Dockerfile
ADD app app/
ADD app /opt/app/
ADD test_* /home/tests
ADD --chown=777:group script.sh /scripts
ADD file.tar.gz /home
ADD https://github.com/coder/repo/mix.exs .
```

### ENV

[ENV reference](https://docs.docker.com/engine/reference/builder/#env)

`ENV` establece la variable de entrada como par valor. Este valor estará en el entorno para todas las siguientes instrucciones en el `build stage`.

```Dockerfile
...
ENV PATH /home/example
ENV PORT 80
ENV CONFIGURATION ./default.cfg
...
```

### WORKDIR

[WORKDIR reference](https://docs.docker.com/engine/reference/builder/#workdir)

`WORKDIR` establece el directorio de trabajo para RUN, CMD, ENTRYPOINT, COPY y ADD que la siga en un `Dockerfile`. Si el `WORKDIR` no existe, será creado incluso si no se usa en sucesivas instrucciones.

La instrucción `WORKDIR` puede ser usada múltiples veces en un `Dockerfile`. Si se provee una ruta relativa, será relativa a la instrucción `WORKDIR` previa. Por ejemplo:

```Dockerfile
WORKDIR /a
WORKDIR b
WORKDIR c
RUN pwd
```

El resulatdo de `pwd` será `/a/b/c`

`WORKDIR` Puede resolver variables de entorno.

```Dockerfile
...
WORKDIR /home
WORKDIR ${PATH}
...
```

### EXPOSE

[EXPOSE reference](https://docs.docker.com/engine/reference/builder/#expose)

```Dockerfile
...
EXPOSE 80
EXPOSE 80/tcp
EXPOSE 80/udp
...
```

### ENTRYPOINT

[ENTRYPOINT reference](https://docs.docker.com/engine/reference/builder/#entrypoint)

* Tiene dos formatos:
    - El _exec form_: `ENTRYPOINT ["executable", "param1", "param2"]`
    - El _shell form_: `ENTRYPOINT command param1 param2`

`ENTRYPOINT` permite configurar un contenedor que se ejucatará como `executable` 

```Dockerfile
...
ENTRYPOINT ["python3", "/opt/app/main.py"]
ENTRYPOINT python3 /opt/app/main.py
...
```

### CMD

[CMD reference](https://docs.docker.com/engine/reference/builder/#cmd)

* La instrucción `CMD` tiene tres formas:
    * CMD ["executable","param1","param2"] (exec form, this is the preferred form)
    * CMD ["param1","param2"] (as default parameters to ENTRYPOINT)
    * CMD command param1 param2 (shell form)

* Sólo puede haber una instrucción `CMD` por `Dockerfile`. Si hay más de un `CMD`, sólo el último tomará efecto.

> La _exec form_  es parseada como un array JSON, lo que signifcia que debemos usar `"` en vez `'`.

```Dockerfile
...
CMD ["python3", "/opt/app/main.py"]
CMD python3 /opt/app/main.py
CMD /opt/app/main.py
...
```

### ENTRYPOINT and CMD

> Article reference: https://goinbigdata.com/docker-run-vs-cmd-vs-entrypoint/

[Understand how CMD and ENTRYPOINT interact](https://docs.docker.com/engine/reference/builder/#understand-how-cmd-and-entrypoint-interact)

Ambas `CMD` y `ENTRYPOINT` definen que comandos se ejecutan cuando ejecutamos un contenedor. Existen algunas reglas que describen su cooperación.


1. `Dockerfile` debe especificar al menos un `CMD` o `ENTRYPOINT`.

2. `ENTRYPOINT` debe ser definido cuando nuestro contenedor va a ser usado como un ejecutable.

3. `CMD` debe ser usado como una manera de definir los argumentos por defecto para un `ENTRYPOINT` o para ejecutar un `ad-hoc command` en un contenedor.

4. `CMD` será sobrescrito cuando ejecutemos el contenedor con comandos alternativos.

|                            |        No ENTRYPOINT       | ENTRYPOINT exec_entry p1_entry | ENTRYPOINT ["exec_entry", "p1_entry"]          |
|:--------------------------:|:--------------------------:|--------------------------------|------------------------------------------------|
|           No CMD           |     error, not allowed     | /bin/sh -c exec_entry p1_entry |               exec_entry p1_entry              |
| CMD ["exec_cmd", "p1_cmd"] |       exec_cmd p1_cmd      | /bin/sh -c exec_entry p1_entry |       exec_entry p1_entry exec_cmd p1_cmd      |
| CMD ["p1_cmd", "p2_cmd"]   |        p1_cmd p2_cmd       | /bin/sh -c exec_entry p1_entry |        exec_entry p1_entry p1_cmd p2_cmd       |
|     CMD exec_cmd p1_cmd    | /bin/sh -c exec_cmd p1_cmd | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd |

> NOTA: Si _CMD_ está definido desde la imagen base, establecer _ENTRYPOINT_ reseteará _CMD_ a un valor vacío. En este escenario, _CMD_ debe de ser definido en la imagen actual para tener un valor.

[Demo 00 Understanding RUN CMD and ENTRYPOINT]('02_docker/01_images/00_understanding_run_cmd_entrypoint/readme.md')

### USER

[USER reference](https://docs.docker.com/engine/reference/builder/#user)

```Dockerfile
...
USER admin
...
```

> Cuando el usuario no tiene establecido un grupo primario entonces la imagen (o la siguiente instrucción) se ejecutará con `root group`.

### ARG

[ARG reference](https://docs.docker.com/engine/reference/builder/#arg)

```Dockerfile
...
ARG arg1
ARG arg2=default
...
```

### SHELL

[SHELL reference](https://docs.docker.com/engine/reference/builder/#shell)

Permite sobreescriber la shell por defecto. Debe ser escrita en formato _JSON_ en un `Dockerfile`.

```Dockerfile
...
SHELL ["/bin/sh", "-c"]
...
```

### LABEL

[LABEL reference](https://docs.docker.com/engine/reference/builder/#label)

Añade metadata a una imagen.

```Dockerfile
...
LABEL organization="MyCompany"
...
```

### .dockerignore file

[.dockerignore reference](https://docs.docker.com/engine/reference/builder/#dockerignore-file)

Todos los ficheros o directorios escritos en `.dockerignore` no serán copiados a la imagen. Normalemente se suelen añadir los mismos valores que `.gitignore`.

```
credentials.secret
my_password.txt
node_modules
npm-debug.log
```

> A Docker image is composed by other images called layers.
> Una imagen de Docker está compuesta de otras imágenes que reciben el nombre de capas.

`Images are composed by several layers`

```bash
Step 1/6 : FROM node:6.17.0-stretch-slim
 ---> b064644cf368
Step 2/6 : WORKDIR /opt/app
 ---> Using cache
 ---> 9f589169aa97
Step 3/6 : COPY . .
 ---> Using cache
 ---> 1809365d6ae8
Step 4/6 : RUN npm install --only=production
 ---> Using cache
 ---> 62690c26e8ff
Step 5/6 : EXPOSE 8080
 ---> Using cache
 ---> aec7425ad91e
Step 6/6 : CMD npm start
 ---> Using cache
 ---> 635e29ab07e4
Successfully built 635e29ab07e4
```