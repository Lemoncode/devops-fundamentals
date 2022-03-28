FROM jenkinsci/blueocean:latest

USER root

# insatll node
RUN apk add --update nodejs npm

# compose deps
RUN apk add --no-cache \
  gcc \
  libc-dev \
  libffi-dev \
  make \
  openssl-dev \
  python3-dev \
  py-pip \
  cargo

# install docker-compose via python 
RUN pip install docker-compose

# .NET Core deps
RUN apk add --no-cache \
  ca-certificates \
  icu-libs \
  krb5-libs \
  libgcc \
  libintl \
  libssl1.1 \
  libstdc++ \
  zlib

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT="true" \
  PATH="${PATH}:/root/.dotnet"

# .NET Core SDK
# see https://github.com/dotnet/dotnet-docker/blob/master/3.1/sdk/alpine3.11/amd64/Dockerfile
RUN dotnet_sdk_version=3.1.201 \
  && wget -O dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-linux-musl-x64.tar.gz \
  && dotnet_sha512='9a8f14be881cacb29452300f39ee66f24e253e2df947f388ad2157114cd3f44eeeb88fae4e3dd1f9687ce47f27d43f2805f9f54694b8523dc9f998b59ae79996' \
  && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
  && mkdir -p /usr/share/dotnet \
  && tar -C /usr/share/dotnet -oxzf dotnet.tar.gz \
  && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
  && rm dotnet.tar.gz \
  # Trigger first run experience by running arbitrary cmd
  && dotnet help

# Install Kubectl
RUN apk add --update ca-certificates \
  && apk add --update -t deps curl \
  && export ARCH="$(uname -m)" && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; fi && curl -L https://storage.googleapis.com/kubernetes-release/release/v1.19.0/bin/linux/${ARCH}/kubectl -o /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && apk del --purge deps \
  && rm /var/cache/apk/*

# Install aws
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
RUN aws --version

# Configure region. To setup credentials we need to provide via file or set up inside the running container
RUN aws configure set region eu-west-3

USER jenkins