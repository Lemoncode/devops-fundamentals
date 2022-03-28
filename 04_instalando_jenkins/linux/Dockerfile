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