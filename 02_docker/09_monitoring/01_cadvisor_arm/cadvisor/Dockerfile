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