## In a nutshell

* **RUN** executes command(s) in a new layer and creates a new image. E.g., it is often used for installing software packages.
* **CMD** sets default command and/or parameters, which can be overwritten from command line when docker container runs.
* **ENTRYPOINT** configures a container that will run as an executable.

Crear un `Dockerfile` como base para la demo

### Shell form 

```Dockerfile
FROM ubuntu:20.04

USER root 

RUN apt update
RUN apt install --yes software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install --yes python3.7

CMD echo "Hello World"
ENTRYPOINT echo "Hello World"
```

Cuando construimos el contenedor, por cada una de las instrucciones anteriores se añade una nueva capa, las dos últimas capas se _ejecutarán_ cuando arranquemos el contenedor, llamando a shell form `/bin/sh -c <command>` 

Construimos la imagen anterior

```bash
docker build -t jaimesalas/run-cmd-entry .
```

Si ejecutammos un contenedor a partir de la imagen anterior:

```bash
$ docker run --rm  -it jaimesalas/run-cmd-entry 
Hello World
```

Modifiquemos la imagen anterior para alimentar una variable de entorno:

```diff
FROM ubuntu:20.04

USER root 

RUN apt update
RUN apt install --yes software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install --yes python3.7

CMD echo "Hello World"
+
+ENV name Jon Snow
+
-ENTRYPOINT echo "Hello World"
+ENTRYPOINT echo "Hello, ${name}"
```

```bash
$ docker build -t jaimesalas/run-cmd-entry .
...
$ docker run --rm  -it jaimesalas/run-cmd-entry 
Hello, Jon Snow
```

La variable `name` es remplazada con su valor.

### Exec form

Esta es la forma preferida para ejecutar `CMD` y `ENTRYPOINT`. `<instruction> ["executable", "param1", "param2"]`

```Dockerfile
FROM ubuntu:20.04

USER root 

RUN ["apt", "update"]
RUN ["apt", "install", "--yes", "software-properties-common"]
RUN ["add-apt-repository", "ppa:deadsnakes/ppa"]
RUN ["apt", "install", "--yes", "python3.7"]

CMD ["/bin/echo", "Hello World"] 

ENV name Jon Snow

ENTRYPOINT ["/bin/echo", "Hello, ${name}"]

```

Ahora procedemos a construir la imagen y ejecutar el contenedor. Notar que la instalación ahora genera nuevas layers.

```bash
$ docker build -t jaimesalas/run-cmd-entry .
...
$ docker run --rm  -it jaimesalas/run-cmd-entry 
Hello, ${name} /bin/echo Hello World
```

La variable de entorno no ha sido substituida.

### ¿Cómo ejecutar bash?

Si necesitamos ejecutar `bash` o cualquier otro iterprete, usamos _exec form_ con `/bin/bash` como ejecutable. En este caso se realizará un proceso de `bash`.

```Dockerfile
FROM ubuntu:20.04

USER root 

RUN ["apt", "update"]
RUN ["apt", "install", "--yes", "software-properties-common"]
RUN ["add-apt-repository", "ppa:deadsnakes/ppa"]
RUN ["apt", "install", "--yes", "python3.7"]

CMD ["/bin/echo", "Hello World"] 

ENV name Jon Snow

ENTRYPOINT ["/bin/bash", "-c", "echo Hello, ${name}"]

```

Si construimos y ejecutamos la imagen, obtenemos:

```bash
$ docker build -t jaimesalas/run-cmd-entry .
...
$ docker run --rm  -it jaimesalas/run-cmd-entry 
Hello, Jon Snow
```

### CMD Review

La instrucción CMD permite establecer un comando por _defecto_, que será ejecutado sólo cuando ejecutemos un contenedor sin especificar un comando. Si el contenedor de Docker se ejecuta con un comando, el comando por defecto será ignorado. Si el Dockerfile tiene más de un CMD, todas las instrucciones CMD será ignoradas excepto la última.

* CMD ["executable", "param1", "param2"] (exec form, preferred)
* CMD ["param1", "param2"] (sets additional default parameters for ENTRYPOINT in exec form)
* CMD command param1 param2 (shell form)

La primera y la tercera ya las hemos visto en acción. La segunda se utiliza junto con `ENTRYPOINT` en _exec form_. Establece valores por defecto que serán añadidos después de los parámetros de `ENTRYPOINT` si el contenedor se ejecuta sin argmentos en la línea de comandos.

```Dockerfile
FROM ubuntu:20.04

USER root 

RUN ["apt", "update"]
RUN ["apt", "install", "--yes", "software-properties-common"]
RUN ["add-apt-repository", "ppa:deadsnakes/ppa"]
RUN ["apt", "install", "--yes", "python3.7"]

CMD echo "Hello World" 

```

Si construimos y ejecutamos la imagen, obtenemos:

```bash
$ docker build -t jaimesalas/run-cmd-entry .
...
$ docker run --rm  -it jaimesalas/run-cmd-entry 
Hello World
```

Pero cuando ejecutamos el contenedor con un comando determinado obtenemos:

```bash
$ docker build -t jaimesalas/run-cmd-entry .
...
$ docker run --rm  -it jaimesalas/run-cmd-entry  /bin/bash
root@248fd9d5a523:/#
```

### ENTRYPOINT Review

`ENTRYPOINT` permite configurar un contenedor que se ejecutará coomo ejecutable. Se parece a CMD, porque también especificamos un comando con parametros. La diferencia es que la instrucción `ENTRYPOINT` y los parametros no son ignorados cuando Docker se ejecuta con argumentos de comando de línea.

> NOTA: Existe una manera de ignorarlo pero no se considera buena práctica.

* ENTRYPOINT ["executable", "param1", "param2"] (exec form, preferred)
* ENTRYPOINT command param1 param2 (shell form)

#### Exec form

_Exec form_ de `ENTRYPOINT` permite establecer los comandos y parametros y después usa tanto la forma de CMD para establecer parametros adicionales que son más comunes de ser cambiados. Los argumentos de `ENTRYPOINT` son siempre usados, mientras que los de CMD pueden ser sobresctitos mediante argumentos de la línea de comandos cuando el contenedor es ejecutado.

```Dockerfile
FROM ubuntu:20.04

USER root 

RUN ["apt", "update"]
RUN ["apt", "install", "--yes", "software-properties-common"]
RUN ["add-apt-repository", "ppa:deadsnakes/ppa"]
RUN ["apt", "install", "--yes", "python3.7"]

ENTRYPOINT ["/bin/echo", "Hello"]
CMD ["World"]

```

Cuando ejecutamos el contenedor obtenemos la siguiente salida:


```bash
$ docker build -t jaimesalas/run-cmd-entry .
...
$ docker run --rm  -it jaimesalas/run-cmd-entry
Hello World
```

Pero cuando le pasamos `Jon` desde la consola:

```bash
$ docker run --rm  -it jaimesalas/run-cmd-entry Jon
Hello Jon
```

### Shell form

Simplemente ignora cualquier CMD o comando de linea.

## Conclusiones

* `RUN` se utiliza para construir imágenes
* Es preferible usar `ENTRYPOINT` a `CMD` cuando construimos imágenes ejecutables con Docker y siempre se necesita un comando para ser ejecutado. De manera adicional usamos `CMD` si necesitamos proveer argumentos extras por defecto que puedan ser sobreescritos desde la línea de comados cuando los contenedores se ejecutan.
* Elegimos `CMD` si necesitas proveer un comando por defecto y/o argumentos que puedenser sobreescritos desde la línea de comandos cuando se ejecuta el contenedor.

## Referencias

Esta demo está extaraida del siguiente artículo: https://goinbigdata.com/docker-run-vs-cmd-vs-entrypoint/
