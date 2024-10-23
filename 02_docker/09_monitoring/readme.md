# Monitoring

Para tomar métricas de los contonedores vamos a use [cAdvisor](https://github.com/google/cadvisor). Para explicar qué es `cAdvisor`, lo mejor, es tomar la descripción expuesta en GitHub:

> cAdvisor (Container Advisor) provides container users an understanding of the resource usage and performance characteristics of their running containers. It is a running daemon that collects, aggregates, processes, and exports information about running containers. Specifically, for each container it keeps resource isolation parameters, historical resource usage, histograms of complete historical resource usage and network statistics. This data is exported by container and machine-wide.

```bash
VERSION=v0.36.0
 docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:$VERSION
```


## References

https://prometheus.io/docs/guides/cadvisor/
https://github.com/google/cadvisor
https://blog.ayjc.net/posts/cadvisor-arm/

[Runtime Metrics](https://docs.docker.com/config/containers/runmetrics/)
[Collect metrics with Prometheus](https://docs.docker.com/config/daemon/prometheus/)