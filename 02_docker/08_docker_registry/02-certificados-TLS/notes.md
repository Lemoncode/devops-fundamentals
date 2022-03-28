# Conexión cifrada con certificados TLS

Los pasos para generar un certificado serían los siguientes:

1. Proveer una `Certificate Authority`
2. Soliicitar `Certificate Sign Request`
3. Generar el certificado

Usaremos Docker en concreto la imagen `squareup/certstrap`

Podemos securizar nuestro registry utilizando certificados. Podemos generar certificados autofirmados de forma sencilla de la siguiente manera:

```bash
# Crearemos un volumen nuevo para los certificados
$ docker volume create registry-certs

# Creamos la Certificate Authority
$ docker run --rm -it -v registry-certs:/out squareup/certstrap init --common-name registry.ca

# Creamos un Certificate Sign Request
# Si necesitamos que referencie una IP, hay que añadir al siguiente comando todas las IPs separadas por comas:
# -ip <ip1>,<ip2>,<etc>
# Si necesitamos que referencie varios nombres de dominio hay que añadirlos al --comon-name separados por comas:
# --common-name registry.intranet,registry.midominio.com,privateregistry.intranet
$ docker run --rm -it -v registry-certs:/out squareup/certstrap request-cert --common-name registry.intranet

# Generamos el certificado
docker run --rm -it -v registry-certs:/out squareup/certstrap sign registry.intranet --CA registry.ca
```

Con estos pasos tendremos a nuestra disposición el certificado registry.crt junto a su clave registry.key. Para usarlos en nuestro registry nos aseguraremos de que el volumen esté montado en el contenedor y le indicaremos la ruta a los ficheros mediante variables de entorno:

```bash
# Borramos el contenedor
$ docker rm -fv registry

# Creamos el registry
$ docker run \
  -d \
  -p 5000:443 \
  --name registry \
  -v registry-data:/var/lib/registry \
  -v registry-certs:/certs:ro \
  -v registry-auth:/auth:ro \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  -e "REGISTRY_HTTP_ADDR=0.0.0.0:443" \
  -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.ca.crt" \
  -e "REGISTRY_HTTP_TLS_KEY=/certs/registry.ca.key" \
  registry:2
```

> Lo ideal sería tener sólo registry.ca.crt y registry.ca.key disponible sin exponer la CA u otros ficheros.

## Acceso al registry en una pipeline con Jenkins

### Host Discovery

El primer paso es asegurarse de que la máquina donde se ejecute Jenkins sea capaz de conectar con la máquina donde esté corriendo el registry. Es importante saber de antemano cómo va a referenciar Jenkins a la máquina del registry, si por IP o por FQDN (nombre de dominio). En caso de usar un FQDN, es importante que sea un dominio completo y no un simple alias como `registry`, ya que a la hora de ser referenciado por Docker dentro de la pipeline nos puede dar problemas. Por ejemplo:

La imagen `registry/my-image` pese a estar prefijada con el nombre de un host accesible es malinterpretado por Docker, y no lo entiende como un registry privado, si no una combinación de `<user>/<repo>` para Docker Hub. Para que Docker entienda que `registry` es el nombre del host que tiene el registry, hay que **añadir el puerto del registry** a la imagen, ya sea `registry:80/my-image` o `registry:443/my-image`. Sin embargo, utilizando un FQDN como `registry.intranet/my-image` evitamos este problema.

Si la máquina donde tenemos alojado el registry no dispone de un FQDN siempre podemos tirar de la vía rápida y añadir una entrada en el fichero `/etc/hosts` de la máquina de Jenkins como la siguiente:

```
172.16.43.101       registry.intranet
```

donde `172.16.43.101` es la IP de la máquina que contiene  el registry y `registry.intranet` el FQDN.

> **IMPORTANTE:** Es muy importante que el certificado referencie el FQDN y/o la IP del registry para que los clientes no tengan errores de certificado cuando realicen peticiones TLS.

## Encriptación entre registry y el demonio de docker que usa Jenkins

Para asegurar que la comunicación entre el registry y el demonio de Docker, de el que Jenkins hace uso durante la ejecución de la pipeline, está cifrada; es necesario crear certificados para Docker utilizando la misma CA privada que utilizamos para crear los certificados del registry. Si el demonio de Docker está en una máquina distinta al registry se pueden generar los certificados y posteriormente copiarlos.

Dentro de la máquina donde corra el demonio de Docker es importante que los certificados estén dentro de `/etc/docker/certs.d/<registry_name>`. En nuestro ejemplo, concordando con el el nombre del host que pusimos en `/etc/hosts` sería `/etc/docker/certs.d/registry.intranet/`. Dentro de ese directorio deberemos tener los siguientes ficheros:

* `ca.crt` El certificado de la CA que firmó los certificados tanto del registry como del cliente.
* `client.cert` El certificado cliente que hemos generado usando la CA. Es importante que tenga la extensión `.cert`, de lo contrario será interpretado como una CA y no como un certificado cliente.
* `client.key` La clave del certificado. Es importante que se el nombre coincida con el del certificado (en nuestro caso `client`) llame `client.key` , de lo contrario tendremos fallos de que no encuentra la clave privada.

## Demo: Acceso al registry desde una pipeline de Jenkins

[Acceso al registry desde una pipeline de Jenkins](02-certificados-TLS/02-jenkins-access-private-registry)
