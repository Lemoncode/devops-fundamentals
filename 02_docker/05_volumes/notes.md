## Volumes

Los `Volumes` son mecanismos para persistir el `data` fuera de un `running container`, separando el ciclo de vida del contenedor del `data`.

Mientras `bind mounts` son dependientes de la estructura de directorios y OS del `host`, __los volumes son completamnete gestionados por Docker__. Los `volumes` tienen las siguientes ventajas frente a `bind mounts`:

* Con los `volumes` es más fácil hacer back up o migrar que con `bind mounts`
* Los `volumes` se pueden gestionar a través de `Docker CLI` o la `Docker API`
* Los `volumes` funcionan tanto en Linux como en Windows.
* Los `volumes` pueden ser compartidos de manera más segura entre múltiples contenedores.
* Los `volume drivers` permite almacenamiento en hosts remotos o proveedores de cloud, para encriptar el contenido de un volumen, o añadir otras funcionalidades.
* Los nuevos volumenes pueden ser inicializados por un contenedor. 
* Los `volumes` en `Docker Desktop` tienen mucha mejor performance que `bind mounts`, tanto en Mac como en Windows.

Los `volumes` suelen ser una mejor opción que persistir el `data` en la capa de escritura de un contenedor, porque sl volumen no aumenta el tamaño del contenedor que lo usa, y el contenido del volumen esta fuera del ciclo de vida del contenedor.

### Choose the -v or --mount flag

En general, `--mount` es más explicito y verboso. La gran diferenca es que la sintaxis `-v` combina todas las opciones en un solo campo, mientras que `--mount` las separa. Veamos una compartiva de ambas sintaxis.

Para especificar las opciones de `volume driver`, se debe usar `--mount`

* `-v` or `--volume`: Consists of three fields, separated by colon characters (:). The fields must be in the correct order, and the meaning of each field is not immediately obvious.
    - In the case of named volumes, the first field is the name of the volume, and is unique on a given host machine. For anonymous volumes, the first field is omitted.
    - The second field is the path where the file or directory are mounted in the container.
    - The third field is optional, and is a comma-separated list of options, such as ro. These options are discussed below.

* `--mount`: Consists of multiple key-value pairs, separated by commas and each consisting of a <key>=<value> tuple. The `--mount` syntax is more verbose than `-v` or `--volume`, but the order of the keys is not significant, and the value of the flag is easier to understand.
    - The `type` of the mount, which can be `bind`, `volume`, or `tmpfs`. This topic discusses volumes, so the type is always volume.
    - The `source` of the mount. For named volumes, this is the name of the volume. For anonymous volumes, this field is omitted. May be specified as `source` or `src`.
    - The `destination` takes as its value the path where the file or directory is mounted in the container. May be specified as `destination`, `dst`, or `target`.
    - The `readonly` option, if present, causes the bind mount to be mounted into the container as read-only.
The volume-opt option, which can be specified more than once, takes a key-value pair consisting of the option name and its value.

### Differences between -v and --mount behavior

Al contrario de `bind mounts`, todas las opciones de `volume` están disponibles en ambos flags `--mount` y `-v`.

## Create and manage volumes

#### Create a volume 

```bash
docker volume create test-vol
```

#### List volumes

```bash
docker volume ls 
```

#### Inspect a volume:

```bash
docker volume inspect test-vol
[
    {
        "CreatedAt": "2020-11-11T09:43:37Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/test-vol/_data",
        "Name": "test-vol",
        "Options": {},
        "Scope": "local"
    }
]
```

#### Remove a volume:

```bash
docker volume rm test-vol
```

## Start a container with a volume

Si arranacas un contenedor con un `volume` que todavía no existe, `Docker` crea el `volume` por ti.

```bash
# mount syntax
docker run -d \
  --name mynginx \
  --mount source=myvol,target=/app \
  nginx:latest
```

```bash
# -v syntax
docker run -d \
  --name mynginx \
  -v myvol:/app \
  nginx:latest
```

```bash
docker inspect mynginx
"Mounts": [
            {
                "Type": "volume",
                "Name": "myvol",
                "Source": "/var/lib/docker/volumes/myvol/_data",
                "Destination": "/app",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
              }
        ]
```

## Populate a volume using a container

Si arrancas un contenedor el cual crea un nuevo `volume`, y el contenedor tiene ficheros o directorios en el directorio que es `mount point`, el contenido del directorio es copiado al `volume`. El contenedor después monta (mounts) y usa el `volume`, y otros contenedores, los cuales usen el `volume` también tienen acceso al contenido `pre cargado`.

Por ejemplo, podemos hacer esto:

```bash
# mount
docker run -d \
  --name=nginxtest \
  --mount source=nginx-vol,destination=/usr/share/nginx/html \
  nginx:latest
```

```bash
# -v
docker run -d \
  --name=nginxtest \
  -v nginx-vol:/usr/share/nginx/html \
  nginx:latest
```

Ahora que tenemos un contenedor que carga un `volume`, vamos a comprobar que tenemos acceso desde otro contenedor

```bash
docker run -v nginx-vol:/usr -it busybox
```

```bash
Unable to find image 'busybox:latest' locally
latest: Pulling from library/busybox
9758c28807f2: Pull complete 
Digest: sha256:a9286defaba7b3a519d585ba0e37d0b2cbee74ebfe590960b0b1d6a5e97d1e1d
Status: Downloaded newer image for busybox:latest
/ # ls
bin   dev   etc   home  proc  root  sys   tmp   usr   var
/ # ls usr
50x.html    index.html
/ # cat usr/index.html
```

## Use a read-only volume

Para el desarrollo de algunas aplicacione, el contenedor necesita escribir en el `bind mount` para que los cambios sean propagados al `Docker Host`. En otras ocasiones el contenedor sólo necesita `read access`. Debemos recordar que múltiples contenedores pueden montar eñ mismo `volume`, y puede ser `read-write` para algunos y `read-only` para otros, al mismo tiempo.

```bash
# mount
docker run -d \
  --name=nginxtest \
  --mount source=nginx-vol,destination=/usr/share/nginx/html,readonly \
  nginx:latest
```

```bash
# -v
docker run -d \
  --name=nginxtest \
  -v nginx-vol:/usr/share/nginx/html:ro \
  nginx:latest
```

```bash
docker inspect nginxtest
"Mounts": [
    {
        "Type": "volume",
        "Name": "nginx-vol",
        "Source": "/var/lib/docker/volumes/nginx-vol/_data",
        "Destination": "/usr/share/nginx/html",
        "Driver": "local",
        "Mode": "",
        "RW": false,
        "Propagation": ""
    }
],
```

## Backup, restore, or migrate data volumes

Los `volume` son útiles para `backups`, `restore` y migraciones. Usamos el flag `--volumes-from` para crear un nuevo contenedor que monte ese volumen.

Esto abre una puerta interesante, porque podemos especificar un `path` en el `host` donde podemos poner algunos ficheros, así cuando el contenedor arranque y el `volume` es inicializado, el contenedor va a tener esos ficheros.

## Use bind mounts

`Bind mounts` tiene una funcionalidad limitada comparada con los `volume`.

Cuando usamos __bind mount__, un __fichero o directorio del host es montado en el contenedor__. El fichero o directorio es referenciado por su __path absoluto en la máquina host__. Por otro lado, cuando usas un `volume`, un nuevo directorio es creado dentro del directorio de almacenamiento de Docker en la máquina host, y Docker gestiona el contenido del directorio.

El fichero o directorio no necesita existir en el `Docker host`. Es creado bajo demanda si todavía no existe. `Bind mounts` tienen muy buena `performance`, pero se asientan el `host filesystem` teniendo una etructura de directorios específica. Si estamos generando nuevas aplicaciones con Docker, consideremos usar `named volumes` en su lugar. No se pueden usar comandos de Docker CLI para gestionar `bind mounst`.

### Choose the -v or --mount flag

Tenemos las mismas opciones que con `volumes`

### Differences between -v and --mount behavior

If you use `-v` or `--volume` to bind-mount a file or directory that does not yet exist on the Docker host, `-v` _creates the endpoint for you_. __It is always created as a directory.__

If you use `--mount` to bind-mount a file or directory that _does not yet exist on the Docker host_, Docker does not automatically create it for you, but __generates an error__.

[Demo Setup App with Volumes]('05_volumes/00_setup_app')

## Use tmpfs mounts

Los `volume` y `bind mounts` permite compartir ficheros entre el `host` y el contenedor para así persistir el `data` incluso cuando el contenedor es parado.

Si corremos Docker en Linux, tenemos una tercera opción: `tmpfs` mounts. Cuando creamos un contenedor con `tmpfs` mount, el contenedor puede crear ficheros fuera de la capa de escritura del mismo.

Al contrario que los `volume` y `bind mounts`, un `tmpfs` mount es temporal, y sólo persiste en el host en memoria. Cuando el contenedor para, el `tmpfs` mount es eliminado, y los ficheros escritos no serán persistidos.

Esto es útil para almacenar temporalmente almacenar ficheros con `sensitive data` que no se quieran persistir ni en el host o en la capa de escritura del contenedor.

## Usando Docker y Basses de Datos

Obviamente gracias a los volúmenes podemos correr bases de Datos, vamos a hacer un dos demos para ver como se usan en el día a día del desarrollo.

[Demo: Initializing a Database]('05_volumes/01_initializing_a_database)

[Demo: Integration Tests](02_integration_test)