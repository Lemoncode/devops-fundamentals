## Navegar por el sistema de ficheros

Cuando abrimos una terminal arrancamos desde el directorio del usuario, podemos saber en que directorio estamos viendo el nombre antes del caracter `$`

```
Jaimes-MacBook-Pro:~ jaimesalaszancada$
```

`~` es un caracter especial que representa el directorio `home` del usuario actual.

```
Jaimes-MacBook-Pro:~ jaimesalaszancada$ pwd
/Users/jaimesalaszancada
```

__pwd__ nos muestra por panatalla el `path` absoluto de nuestro directorio de trabajo, podemos cambiar nuestro directorio de trabajo utilizando __cd__. Una vez que nos movemos por los distintos directorios queremos ver el contenido de los mismos:

* __ls__ nost permite listar los distintos ficheros y directorios del directorio en el que nos encontarmos. 
* __ls -l__ con el `flag` **-l** nos da información acerca del contenido.

```
Jaimes-MacBook-Pro:async-javascript-fundamentals jaimesalaszancada$ ls -l
total 24
drwxr-xr-x   6 jaimesalaszancada  staff   192 Jul 25 18:43 01 Non blocking
drwxr-xr-x   6 jaimesalaszancada  staff   192 Jul 25 18:43 10 Event listeners are sync
drwxr-xr-x  16 jaimesalaszancada  staff   512 Jul 26 21:31 11 Axios
drwxr-xr-x   7 jaimesalaszancada  staff   224 Jul 25 18:44 12 Promises
drwxr-xr-x   6 jaimesalaszancada  staff   192 Jul 26 22:30 13 Fetch
drwxr-xr-x   7 jaimesalaszancada  staff   224 Jul 28 19:43 14 Async await
-rw-r--r--   1 jaimesalaszancada  staff   554 Jul 25 18:43 README.md
drwxr-xr-x   5 jaimesalaszancada  staff   160 Jul 25 18:44 auth
-rw-r--r--   1 jaimesalaszancada  staff   356 Jul 26 20:39 docker-compose.yml
drwxr-xr-x   7 jaimesalaszancada  staff   224 Jul 25 18:44 server-in-memory
drwxr-xr-x  19 jaimesalaszancada  staff   608 Jul 28 18:36 server-mongo
```

Nos dice que el usuario __jaimesalaszancada__ y el grupo __staff__ son los dueños de los distintos elementos.

* __-a__ nos permite ver los ficheros/directorios ocultos.

```
Jaimes-MacBook-Pro:async-javascript-fundamentals jaimesalaszancada$ ls -la
total 56
drwxr-xr-x  25 jaimesalaszancada  staff    800 Jul 28 19:48 .
drwxr-xr-x   8 jaimesalaszancada  staff    256 Aug  1 22:00 ..
-rw-r--r--@  1 jaimesalaszancada  staff  10244 Jul 26 22:51 .DS_Store
drwxr-xr-x  15 jaimesalaszancada  staff    480 Jul 28 19:48 .git
-rw-r--r--   1 jaimesalaszancada  staff    933 Jul 28 13:20 .gitignore
```

The __.__ stands for the current working directory, and the __..__ stands for the parent directory of the current folder that you're in. These are special folders that the operating system and the filesystem sets up.

El `.` representa el directorio de trabajo actual, y `..` representa el directorio padre del directorio actual en el que nos encontarmos. Estos son directorios especiales que el sistema operativo y sistema de ficheros establece.

Si hacemos `cd ..`, movemos el directorio actual a un nivel superior en la jerarquía de ficheros.

## Ver ficheros y directorios

* __cat__ nos da un vistazo rápido del contenido de un fichero

```
Jaimes-MacBook-Pro:async-javascript-fundamentals jaimesalaszancada$ cat .gitignore
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
```

* __cat <filename> -n__ nos muestra el contenido del fichero con el número de línea.

Si los ficheros son largos un comando mejor para encontrar contenido dentro del ficchero es __less__.

```
Jaimes-MacBook-Pro:async-javascript-fundamentals jaimesalaszancada$ less .gitignore
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

```

__less__ nos da algunas herramientas, mientras estamos dentro de su contexto, para navegar dentro del fichero. __Shift G__ nos lleva al final del fichero y __g__ nos devuelve al principio. Otra de las cosas es hacer `high light` de contenido dentro del fichero.

Si estamos al comienzo del fichero podemos hacer __/yarn__ y resaltara ese termino. Para salir __q__.

## Crear y borrar ficheros y directorios

* __touch <filenname.extension>__ crea un fichero. 

```
Jaimes-MacBook-Pro:work jaimesalaszancada$ touch file.txt
```

En este punto, `file.txt` estará vacío. Vamos a ver como podemos añadir contenido al mismo. Para esto vamos a usar el comando __echo__, este comando es una especie de `logger` en el terminal de Bash. Si hacemos __echo hi__ escupe la string.

```bash
$ echo hi
hi
```

Si hacemos __echo hi__ y usamos el operador `>` hará que `hi` vaya directo al fichero

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ echo 'hi' > file.txt
```

Ahora si miramos el contenido del fichero

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ cat file.txt
hi
```

Si lo hacemos de nuevo con una frase distinta, el contenido del fichero se sobreescribe.

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ echo 'hi again' > file.txt
Jaimes-MacBook-Pro:work jaimesalaszancada$ cat file.txt
hi again
```

Si lo que queremos es añadir contenido al fichero utilizamos `>>`

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ echo 'hello world' >> file.txt
Jaimes-MacBook-Pro:work jaimesalaszancada$ cat file.txt
hi again
hello world
```

Si lo que queremos es inicializar un fichero y añadir contenido de manera inmediata

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ echo 'hello' > file2.txt
Jaimes-MacBook-Pro:work jaimesalaszancada$ cat file2.txt
hello
```

* __mkdir__ genera un nuevo directorio

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ mkdir folder
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
file.txt        file2.txt       folder
```

Podemos ver nuestros dos ficheros creados y nuestro directorio. Digamos que queremos crear múltiples directorios anidados al mismo tiempo, queremos hacer __mkdir a/b/c__. Al intertar esto no nos va a dejar, __mkdir__ por defecto quiere un `path completo`, lo que quiere es que los directorios `a` y `b` existan antes de crear `c`.

Lo que podemos hacer es usar el `flag -p` , que creará esos directorios intermedios cuando los necesite. 

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ mkdir -p a/b/c
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
a               file.txt        file2.txt       folder
```

* __rm__ elimina un fichero de forma permanente. No lo mueve a la papelera ni nada por el estilo.

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ rm file.txt
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
a               file2.txt       folder
```

* __rm__ por defecto sólo elimna ficheros. Si le pasamos el `flag -r` actua de manera recursiva elminando el contenido del directorio.

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ rm -r folder/
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
a               file2.txt
```

En muchas ocasiones, veremos usar `rm` con `-r flag` y `-f flag`. El `-f` es una especie de bomba nuclear, previene que el terminal nos pida confirmación para borrar un fichero, y de escupir un error en el caso de que un directorio o fichero no exista.

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ rm -rf a
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
file2.txt
```

## Mover y copiar ficheros a otros directorios

* __mv__ mueve ficheros y directorios.

En mi directorio tengo un fichero de JS `index.js` y un directorio al mismo nivel `src`. El directorio `src` está vacío. 

Digamos que quiero mover `index.js` a `src`. Primero pasamos el elemnto que queremos mover, y después el destino, en el destino hay que pasar el nombre completo del fichero.

```bash
mv index.js src/index.js
```

Por ejemplo, si sólo quieres renombrar un fichero, creamos un fichero __touch a.js__ y después queremos que `a.js` se llame `b.js`, simplemente lo pasamos al mismo directorio pero con distinto nombre.

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ touch a.js
Jaimes-MacBook-Pro:work jaimesalaszancada$ mv a.js b.js
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
b.js    src
```

En este directorio, tengo el directorio `src`, digamos que lo queremos renobrar a lib.

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ mv src/ lib
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
b.js    lib
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls lib/
index.js
```

Digamos que ahora quiero mover todo lo de `lib` a `src`. Creamos es directorio __$ mkdir src__, y vamos a mover `lib` y con `*`, coge todo el contenido, ficheros y directorios dento del directorio `lib`, y después `src`

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ mkdir src
Jaimes-MacBook-Pro:work jaimesalaszancada$ mv lib/* src
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls lib/
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls src/
index.js
```

* __cp__ copia un fichero.

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ echo 'hello' > README.md
Jaimes-MacBook-Pro:work jaimesalaszancada$ cp README.md > src/README.md
usage: cp [-R [-H | -L | -P]] [-fi | -n] [-apvXc] source_file target_file
       cp [-R [-H | -L | -P]] [-fi | -n] [-apvXc] source_file ... target_directory
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
README.md       b.js            lib             src
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls src/
README.md       index.js
```

Si queremos copiar un directorio entero y todos sus sub-directorios desde uno a otro, usamos `cp` pasando __-R__ (recursivo).

```bash
Jaimes-MacBook-Pro:work jaimesalaszancada$ cp -R src/* lib/
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls
README.md       b.js            lib             src
Jaimes-MacBook-Pro:work jaimesalaszancada$ ls lib/
README.md       index.js
```

## Encontrar ficheros y directorios con 'find'

Tenemos un directorio con éste contenido

```bash
ls images/
bunch-of-kittens.png    just-one-kitten.png     single-kitten.jpg       two-kitten.JPG
```

Digamos que queremos encontrar aquellos con la extensión `*.png`, parace una expresión regular, pero no lo es es simplemente que la `string` con cualquier cosa por delente este ahí. 

```bash
find images/ -name "*.png"
images//just-one-kitten.png
images//bunch-of-kittens.png
```

Si hacemos lo mismo para _.jpg_, sólo tenemos un resultado, esto pasa porque uno de nuestros ficheros esta en mayúscula.

```bash
find images/ -name "*.jpg"
images//single-kitten.jpg
```

Si queremos ignorar mayúsculas y minúsculas podemos usar el flag _-iname_.

```bash
find images/ -iname "*.jpg"
images//single-kitten.jpg
images//two-kitten.JPG
```

Si quermos encontrar los directorios en nuestro directorio actual podemos hacer

```bash
find . -type d
.
./dist
./images
```

Podemos combinar con el flag _-name_

```bash
find . -type d -name "images"
./images
```

* __find__ soporta una acción por cada equivalencia. Queremos borrar todos los ficheros `.js` de este directorio.

```bash
ls dist
kitten.png      main.built.js   vendor.built.js
```

```bash
find dist/ -name "*.built.js" -delete
```

```bash
ls dist/
kitten.png
```

Podemos usar cualquier tipo de comando:

```bash
find images/ -name "*.png" -exec pngquant {} \;
```

* NOTA __pngquant__ hay que instalarlo.

Para ver todas las posibilidades que ofrece un comando podemos usar `man`

```bash
man find
```

## Búsqueda de texto con 'grep'

Queremos encontrar un string en un fichero. Cada línea que devuelve es una equivalencia en el fichero. Las líneas del fichero no pueden ser consecutivas, simplemente devuelve la línea donde aparece la string.

```bash
grep "npm.config.get" lib/npm.js
```

Podemos usarlo para buscar en múltiples ficheros.

```bash
grep "npm.config.get" lib/**/*.js
```

* **--color** colorea la equivalencia 

```bash
grep --color "npm.config.get" lib/npm.js
```

* **-n** establece el númeor de línea en el fichero.

```bash
grep --color -n "npm.config.get" lib/npm.js
```

* -C 1 toma el contexto de la equivalencia dando la línea previa. 
```bash
grep --color -n -C 1 "npm.config.get" lib/npm.js
```

* `grep` soprta expresiones regulares "npm.config.[gs]et"

```bash
grep --color -n -e "npm.config.[gs]et" lib/npm.js
```

## Hacer peticiones HTTP con 'curl'

* Para hacer peticiones HTTP podemos usar __curl__

```bash
curl https://example.com
```

* Podemos usar el flag __-i__ para obtener las cabeceras de la respuesta.

```bash
curl -i https://swapi.co/api/people/2
HTTP/2 301 
date: Tue, 20 Aug 2019 22:27:36 GMT
content-type: text/html; charset=utf-8
set-cookie: __cfduid=d7ba1e91c2af7c4e233db52ea5d458c7e1566340056; expires=Wed, 19-Aug-20 22:27:36 GMT; path=/; domain=.swapi.co; HttpOnly; Secure
x-frame-options: SAMEORIGIN
location: https://swapi.co/api/people/2/
via: 1.1 vegur
expect-ct: max-age=604800, report-uri="https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct"
server: cloudflare
cf-ray: 5097cba629d5c68b-MAD
```

> NOTA: nos está intentanso redirigir a  __location: https://swapi.co/api/people/2/__

* Hagamos la misma petición pero cerrandola con __/__

```bash
curl -i https://swapi.co/api/people/2/
HTTP/2 200 
date: Tue, 20 Aug 2019 22:30:15 GMT
content-type: application/json
set-cookie: __cfduid=d0cd20fd33a8fdc2464cb08841fd2fb311566340212; expires=Wed, 19-Aug-20 22:30:12 GMT; path=/; domain=.swapi.co; HttpOnly; Secure
etag: "3a58f420395ff0deed943e331d3bf74b"
vary: Accept, Cookie
x-frame-options: SAMEORIGIN
allow: GET, HEAD, OPTIONS
via: 1.1 vegur
expect-ct: max-age=604800, report-uri="https://report-uri.cloudflare.com/cdn-cgi/beacon/expect-ct"
server: cloudflare
cf-ray: 5097cf7a8e61d67d-MAD

{"name":"C-3PO","height":"167","mass":"75","hair_color":"n/a","skin_color":"gold","eye_color":"yellow","birth_year":"112BBY","gender":"n/a","homeworld":"https://swapi.co/api/planets/1/","films":["https://swapi.co/api/films/2/","https://swapi.co/api/films/5/","https://swapi.co/api/films/4/","https://swapi.co/api/films/6/","https://swapi.co/api/films/3/","https://swapi.co/api/films/1/"],"species":["https://swapi.co/api/species/2/"],"vehicles":[],"starships":[],"created":"2014-12-10T15:10:51.357000Z","edited":"2014-12-20T21:17:50.309000Z","url":"https://swapi.co/api/people/2/"}
```

* Ahora funciona, podemos obtener el mismo resultado utilizando el flag `L`

```bash
curl -iL https://swapi.co/api/people/2
```

* Vamos a hacer una petición más compleja, por ejmplo con cabeceras.

```bash
curl -H "Authorization: Bearer 123" localhost:3000/api-protected/posts
```

* Utilizando otro verbo HTTP.

```bash
curl -X POST -H "Content-Type: application/json" -d '{ "title": "Curling", "author": "Jai" }' localhost:3000/api-protected/posts
```

* Hacer un post con `url encoded`

```bash
curl -i -X POST --data-urlencode title="More" --data-urlecode author="Jai" localhost:3000/api-protected/posts
```

* Y por supuesto lo podemos escribir en múltiples líneas

```bash
curl -i -X PUT \
> -d '{ "title": "Changed title" }' \
> -H "Content-Type: application/json" \
> http://localhost:3000/api/posts/2
```

* Podemo volcar los resultados a un fichero

```bash
curl -iL https://google.com -o google.txt
```

* __-i__ incluir cabeceras headers
* __L__ seguir redirecciones
* __-o__ volcar los resultados a un fichero.

* Para inspeccionar el resultado

```bash
less google.txt
```