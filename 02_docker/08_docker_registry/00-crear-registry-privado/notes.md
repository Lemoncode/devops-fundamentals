# Docker Registry

## ¿Qué es un registry?

Un registry es un servicio que nos permite almacenar y distribuir imagenes de Docker. Actualmente existe un Registry público llamado [Docker Hub](https://hub.docker.com/) el cual provee su uso de forma pública y gratuita con características adicionales.

## Levanatar un registry privado

Para levantar un registry privado basta con levantar un contenedor de docker utilizando la imagen `registry:2` .

```sh
# Creamos un volumen de persistencia para nuestras imágenes
$ docker volume create registry-data

# Creamos el registry
$ docker run -d -p 5000:5000 -v registry-data:/var/lib/registry --name registry registry:2
```

> `-d` Ejecuta el contenedor en segundo plano
>
> `-v registry-data:/var/lib/registry` Monta el volumen `registry-data` en `/var/lib/registry` del contenedor. También podríamos haber utilizado un mapeo de directorio en vez de un volumen
>
> `-p 5000:5000` Expone al registry al exterior utilizando el puerto `5000` de nuestro host al puerto `5000` del contenedor
>
> `--name registry` Da el nombre `registry` al contenedor
>
> `registry:2` el nombre de la imagen

## Uso básico de un registry

Para almacenar una imagen de docker en nuestro registry tenemos que realizar un pequeño paso tras construir la imagen y es prefijar el nombre y puerto de nuestro registry al nombre de la imagen. Esto le permite a docker saber a qué registry conectarse a la hora de ejecutar comandos como `docker pull` o `docker push`. Veamos un ejemplo:

```bash
# Construimos una imagen
$ docker build -t custom-nginx - <<EOF
FROM nginx:latest
RUN sed -i 's/Welcome to nginx/Welcome to custom nginx/' /usr/share/nginx/html/index.html
EOF

# Prefijamos la imagen con el nombre de nuestro registry
$ docker tag custom-nginx localhost:5000/custom-nginx

# Subimos la imagen al registry
$ docker push localhost:5000/custom-nginx

# Eliminamos las imagenes locales
$ docker rmi nginx custom-nginx localhost:5000/custom-nginx

# Descargar la imagen
$ docker pull localhost:5000/custom-nginx

# Comprobamos que podemos usar la imagen
$ docker run -d -p 80:80 --name custom-nginx localhost:5000/custom-nginx
$ curl localhost:80
```

Esta es la manera más básica de crear y usar un registry. Para eliminarlo ejecutaremos:

```bash
docker stop registry && docker rm -v registry
```

El registry que hemos creado es inseguro. En entornos corporativos no es aceptable y hay que securizarlo utilizando TLS y autenticación.