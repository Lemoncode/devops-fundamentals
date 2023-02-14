
```Dockerfile
FROM golang:buster AS builder
ARG VERSION

RUN apt-get update \
 && apt-get install make git bash gcc \
 && mkdir -p $GOPATH/src/github.com/google \
 && git clone https://github.com/google/cadvisor.git $GOPATH/src/github.com/google/cadvisor

WORKDIR $GOPATH/src/github.com/google/cadvisor
RUN git fetch --tags \
 && git checkout $VERSION \
 && go env -w GO111MODULE=auto \
 && make build \
 && cp ./cadvisor /

# ------------------------------------------
# Copied over from deploy/Dockerfile except that the "zfs" dependency has been removed
# a its not available fro Alpine on ARM
FROM alpine:latest
MAINTAINER dengnan@google.com vmarmol@google.com vishnuk@google.com jimmidyson@gmail.com stclair@google.com

RUN sed -i 's,https://dl-cdn.alpinelinux.org,http://dl-4.alpinelinux.org,g' /etc/apk/repositories

RUN apk --no-cache add libc6-compat device-mapper findutils thin-provisioning-tools && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm -rf /var/cache/apk/*

# Grab cadvisor from the staging directory.
COPY --from=builder /cadvisor /usr/bin/cadvisor

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1

ENTRYPOINT ["/usr/bin/cadvisor", "-logtostderr"]
```

```yaml
version: '3.6'
services:
  cadvisor:
    privileged: true
    container_name: cadvisor
    build:
      context: ./cadvisor
      dockerfile: Dockerfile
      args:
        VERSION: "v0.44.0"
      cache_from:
        - golang:buster
        - alpine:latest
    command:
      - '--allow_dynamic_housekeeping=true'
      - '--housekeeping_interval=30s'
      - '--docker_only=true'
      - '--storage_duration=1m0s'
      - '--event_storage_age_limit=default=0'
      - '--event_storage_event_limit=default=0'
      - '--global_housekeeping_interval=30s'
      - '--disable_metrics=accelerator,cpu_topology,disk,memory_numa,tcp,udp,percpu,sched,process,hugetlb,referenced_memory,resctrl,cpuset,advtcp,memory_numa'
      - '--store_container_labels=false'
    restart: unless-stopped
    devices:
      - /dev/kmsg:/dev/kmsg
    expose:
      - 8080
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /etc/machine-id:/etc/machine-id:ro
      - /var/run/docker.sock:/var/run/docker.sock
```

```bash
docker-compose up -d
```