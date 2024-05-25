FROM jenkins/jenkins:2.426.3-jdk17

USER root

# install docker-cli
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg

RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  
RUN apt-get update && apt-get install -y docker-ce-cli

# install kubectl
RUN curl -LO https://dl.k8s.io/release/v1.29.1/bin/linux/arm64/kubectl
RUN chmod +x kubectl \
    && mv ./kubectl /usr/local/bin/kubectl

# install AWS CLI 2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install -i /usr/local/aws-cli -b /usr/local/bin

USER jenkins

RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
