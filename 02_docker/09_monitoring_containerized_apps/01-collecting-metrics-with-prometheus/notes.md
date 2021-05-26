## Introducción

Un servidor de métricas es un punto central para recolecatr y almacenar datos de monitorización en las aplicaciones contenerizadas. `Prometheus` es el servidor de métricas más popular.

* Open source
* cross-platform
* Docker friendly

## Usando un contenedor para ejecutar Prometheus

`Prometheus` en una aplicación escriat en `GO`, lo que la convierta en ligera y `cross-platform`. `Prometheus` se puede ejecutar directamente en un servidor en tu cluster o en un servidor separado dentro de tu network, además de poderse ejecutar como un contenedor junto con otras aplicaciones contenerizadas.

Recordar que los contenedores en la misma red de `Docker` pueden acceder entre ellos, sin que sus puertos sean expuestos al mundo exterior. Por lo que cuando ejecutamos `Prometheus` como un conetenedor, podemos mantener los `end points` de métricas de manera privada. Podemos incluso hacer lo mismo con el propio `Prometheus` ya que este sólo necesita ser accedido mediante `Grafana`

`Prometheus` es fácilmente configurable para extraer la información de componentes que estén correindo wn múltiples contenedores replicados, ya que `Docker` provee `service discovery`. `Prometheus` necesita almacenar los datos que recopila, para aplicaiones pequeñas, usar un volumen dentro de la red puede estar bien, pero para aplicaciones más grandes se necesitara escalar en un cluster.

## Demo: Running Prometheus in Docker

[Prometheus Docker Image](https://hub.docker.com/r/prom/prometheus/)

```
docker pull prom/prometheus:v2.20.1
```

To run prometheus 

```bash
$ docker container run \
  --detach --publish-all \
  prom/prometheus:v2.20.1
```

```bash
$ docker run --name prometheus -d --publish-all prom/prometheus:v2.20.1
```

```bash
$ docker run --name prometheus -d -p 9090:9090 prom/prometheus:v2.20.1
```

```bash
$ docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                     NAMES
45dfcdfa2ace        prom/prometheus:v2.20.1   "/bin/prometheus --c…"   6 seconds ago       Up 5 seconds        0.0.0.0:32768->9090/tcp   prometheus
```

Este contenedor está ejecutando el setup de Prometheus por defecto que no tienen **ningún job asociado**. Pero si ejecutamos `curl localhost:32768/metrics` podemos ver las metricas que expone `Prometheus`.

## Configuración y Service Discovery con Prometheus

### Prometheus Configuration - Scrape Configs

Vamos a ejecutar el contenedor de  `Prometheus` en la misma red de `Docker` donde se encuentran los contenedores de nuestra aplicación que queremos monitorizar. Podemos configurar `Prometheus` para `preguntar` a esos contenedores cómo `scrape targets`, y establecer un intervalo de tiempo en el cuál `Prometheus` realizará las peticiones HTTP GET a los endpoints de métricas de los contenedores.


```yaml
global:
  scrape_interval: 10s
  ...

scrape_configs:
```

### Prometheus Configuration - Job Configs

La configuración para un `job` es el server `host name` o la `IP y puerto`. Los contenedores usan DNS to para ver otros contenedores dentro de la misma red, si estamos ejecutando los contenedores en modo `swarm`, sólo necesitamos establecer el nombre de la aplicación que queremos monitorizar, y establecer el nombre del contenedor cómo target.

```yaml
- job_name: 'netfx-app'
  metrics_path: /metrics/
  static_configs:
    - targets: ['netfx:50506']
```

## Demo: Configuring Prometheus

[Collect Docker metrics with Prometheus](https://docs.docker.com/config/daemon/prometheus/)

Tenemos que editar este fichero `~/.docker/daemon.json` **Docker daemon**, para que `Prometheus` pueda recoger métricas.

```diff
{
  "debug":true,
- "experimental":false,
+ "experimental":true,
  "insecure-registries":["vps413835.ovh.net:444"],
+ "metrics-addr": "127.0.0.1:9323"
}
```

Now we can add a job to scrap Docker 

```yml
 - job_name: 'docker'
         # metrics_path defaults to '/metrics'
         # scheme defaults to 'http'.

    static_configs:
      - targets: ['docker.for.mac.host.internal:9323']
```

From node folder, we have built a new Docker image

```bash
$ docker build -t aimesalas/node-web-app:0.0.1 .
```

Create a config file for Prometheus _./prometheus/prometheus.yml_

```yml
global:
  scrape_interval: 10s
  external_labels:
    monitor: 'local_monitor'

scrape_configs:


  - job_name: 'node-app'
    metrics_path: /app-metrics/
    static_configs:
      - targets: ['node:3000']

  - job_name: 'docker'
    scrape_interval: 15s
    metrics_path: /metrics
    static_configs:
      - targets: ['docker.for.mac.host.internal:9323']
```

And create a custom Prometheus image, that loads (**TODO: Study load from volume**) the previous configuration

```Dockerfile
FROM prom/prometheus:v2.3.1
COPY prometheus.yml /etc/prometheus/prometheus.yml
```

Build this custom image as follows

```bash
$ docker build -t jaimesalas/prometheus-test:0.0.1 .
```

Now we can create a custom Docker network as follows:

```bash
$ docker nnetwork create -d bridge internal-network
```

Start our containers adding to that network

```bash
$ docker run -d --name node --network=internal-network -p 3000:3000 jaimesalas/node-web-app:0.0.1
```

```bash
$ docker run --name prometheus --network=internal-network -d -p 9090:9090 jaimesalas/prometheus-test:0.0.1
```

If we check our network now, we can find out these two containers

```bash
Jaimes-MacBook-Pro:prometheus jaimesalaszancada$ docker network inspect internal-network
[
    {
        "Name": "internal-network",
        ....
        "ConfigOnly": false,
        "Containers": {
            "484b466d94c73148c32c2ef16028832db6dca35d8d6f344ceb2455d875e72468": {
                "Name": "node",
                "EndpointID": "5b0bd53e5798db80a6f0d7b352304211349fa5c66046d7a4e219820fada03ede",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            },
            "8f5403c2cd84af8885d671dd283b487d8e767ec64bea4e072b6572d41de0852c": {
                "Name": "prometheus",
                "EndpointID": "9326f4c5c7e170fc979682c2eeeab584c587d38ad3fd509acd65eb451eec9eb3",
                "MacAddress": "02:42:ac:12:00:03",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```
