## Autentificación para acceder al registry

El registry soporta autenticación nativa utilizando ficheros `htpasswd` para almacenar los secretos. Vamos a generar un usuario y contraseña.

> **IMPORTANTE:** El tag `:2.7.1` del registry no contiene los binarios de `htpasswd` (y la :2 que actualmente apunta a `:2.7.1`) por lo que utilizaremos el tag `:2.7.0` para generar el fichero. Más información en este [enlace](https://github.com/docker/docker.github.io/issues/11060).

```bash
# Creamos un volumen para contener el fichero de autenticación
$ docker volume create registry-auth

# Generamos el fichero en el volumen utilizando la imagen de registry que contiene el binario montando nuestro volumen
$ docker run --rm \
  -v registry-auth:/auth \
  registry:2.7.0 \
  sh -c "htpasswd -Bbn devops secretpassword >> /auth/htpasswd"

# Verificamos que se ha creado
$ docker run --rm -v registry-auth:/auth registry:2.7.0 cat /auth/htpasswd
devops:$2y$05$Xq.J7dUkOuYqtNtg.phyeOjP0U11WTIqdgTNKGuI9Wh4lWyHhG6De
```

> **IMPORTANTE:** Es posible que contraseñas conteniendo símbolos o caracteres especiales no funcionen de forma correcta al hacer `docker login` de forma interactiva o utilizando `--password-stdin` Hay un [issue](https://github.com/docker/for-linux/issues/1085) abierto al respecto.

Para hacer que el registry use ahora el fichero tenemos que montar el volumen anterior `registry-auth` en la ruta `/auth` del registry e indicar mediante las correspondientes variables de entorno el sistema de autenticación:


```bash
# Borramos el contenedor de datos iniciado anteriormente
$ docker rm -fv registry-data

# Levantamos el registry montando nuestro volumen de autenticación
$ docker run \
  -d \
  -p 5000:5000 \
  --name registry \
  -v registry-data:/var/lib/registry \
  -v registry-auth:/auth:ro \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  registry:2
```

> Cualquier apartado de la configuración del registry se puede configurar mediante variables de entorno. Más información en la documentación sobre [cómo configurar un registry](https://docs.docker.com/registry/configuration/).

Para poder hacer uso del registry debemos de autenticarnos previamente utilizando el usuario y contraseña creados en pasos anteriores:

```bash
# Nos autenticamos contra el registry
$ docker login -u devops -p secretpassword localhost:5000

# Comprobamos que ahora tenemos acceso a las imágenes
$ docker pull localhost:5000/custom-nginx

# Si queremos eliminar las credenciales podemos ejecutar
$ docker logout localhost:5000
```