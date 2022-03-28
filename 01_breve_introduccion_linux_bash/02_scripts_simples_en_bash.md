## Crear y ejecutar scripts con argumentos pasado CLI

```bash
touch script.sh
```

```sh
echo "Hello world"
```

Para ejecutar un script tenemos que referenciar el `path` al script.

```bash
./script.sh
bash: ./script.sh: Permission denied
```

Nos da un negación de permisos. Esto ocurre porque es el modo por defecto cuando se crea un fichero, tienes permisos de escritura y de lectura, pero no de ejecución.

```bash
ls -l
-rw-r--r--  1 jaimesalaszancada  staff  18 21 Aug 00:58 script.sh
```

Vamos a cambiar los permisos sobre este fichero.

```bash
chmod u+x script.sh
```
* _u+x_ signifaca darle permisos de ejecución al usuario.

Si lo volvemos a ejecutar

```bash
./script.sh
Hello world
```

En bash pasamos parámetros en la CLI después del script y separados por un especio, y los podemos referenciar dentro des script por orden. Por ejemplo podemos modificar _scrpt.sh_ de la siguiente manera:

```diff
-echo "Hello world"
+echo "$1 world"
```

Ahora podemos ejecutar: 

```bash
./script.sh hola
hola world
```

## Ejemplo de uso

Hagamos algo más realista, generar la estructura inicial de un nuevo proyecto en JavaScript. Crear `init-js.sh`

```sh
echo "Initializing JS prokect at $(pwd)"
git init 
npm init -y # create package.json withh all defaults
mkdir src
touch src/index.js 
code . # open the current directory
```

No nos olvidemos de darle permisos de ejecución al fichero:

```bash
chmod u+x init-js.sh
```

El problema es que si queremos ejecutar el script en un directorio en particular tenemos que pegarlo y ejecutarlo ahí, como alternativa a esto podemos modificar `PATH`.

```bash
echo $PATH
```

Esto es, una colección de directorio, separados por `:`, donde la `shell` busca los ejecutables.

/Users/jaimesalaszancada/.nvm/versions/node/v10.16.0/bin:
/usr/local/bin:
/usr/bin:
/bin:
/usr/sbin:/sbin:/Users/jaimesalaszancada/.nvm/versions/node/v10.16.0/bin

Podemos localizar un ejecutable en concreto utilizando el comando `which`

```bash
which minikube
/usr/local/bin/minikube
```

> https://gist.github.com/nex3/c395b2f8fd4b02068be37c961301caa7

## Almacenar y Uasar valores con las Variables de Bash

Podemos almacenar y leer unavariable de la siguiente manera:

```bash
$ var=123
$ echo $var
123
```

El alacnace de esta variable es sólo para esta sesión. Esta variable será visible por cualquier script que sea ejecutado en este contexto. Vamos a crear un nuevo script __script_a.sh__, con el siguiente contenido.

```bash
echo $var
```

Le damos permisos

```bash
chmod +x script_a.sh
```

Si lo ejecutamos nos devuelve un espacio en blanco `undefined`.

```bash
./script_a.sh

```

Para hacer que la variable sea visible por un proceso hijo, la necesitamos exportar.

```bash
$ export var
$ ./script_a.sh
123
```

Podemos quitar la variable usando `unset`.

```bash
$ unset var
$ ./script_a.sh 

```

* __bash__ establece muchas variables globales que podemos listar con el comando _env_.

```bash
$ env
TERM_PROGRAM=vscode
NVM_CD_FLAGS=
TERM=xterm-256color
SHELL=/bin/bash
TMPDIR=/var/folders/zh/ckdw3m6x57xdqqwfqnf2jdlc0000gn/T/
Apple_PubSub_Socket_Render=/private/tmp/com.apple.launchd.u7Q6ms8zC1/Render
TERM_PROGRAM_VERSION=1.37.1
NVM_DIR=/Users/jaimesalaszancada/.nvm
USER=jaimesalaszancada
COMMAND_MODE=unix2003
SSH_AUTH_SOCK=/private/tmp/com.apple.launchd.pjIvbru0ZB/Listeners
__CF_USER_TEXT_ENCODING=0x1F5:0:2
PATH=/Users/jaimesalaszancada/.nvm/versions/node/v10.16.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/jaimesa
laszancada/.nvm/versions/node/v10.16.0/bin
PWD=/Users/jaimesalaszancada/Documents/paths/bash-path/00_fundamentals
LANG=en_GB.UTF-8
XPC_FLAGS=0x0
XPC_SERVICE_NAME=0
SHLVL=2
HOME=/Users/jaimesalaszancada
LOGNAME=jaimesalaszancada
NVM_BIN=/Users/jaimesalaszancada/.nvm/versions/node/v10.16.0/bin
COLORTERM=truecolor
_=/usr/bin/env
```

Para referenciar una variable global es exactamente lo mismo que cualquier otra variable.

```bash
$ echo $USER
jaimesalaszancada
```