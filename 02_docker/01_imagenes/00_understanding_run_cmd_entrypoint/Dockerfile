FROM ubuntu:20.04

USER root 

RUN ["apt", "update"]
RUN ["apt", "install", "--yes", "software-properties-common"]
RUN ["add-apt-repository", "ppa:deadsnakes/ppa"]
RUN ["apt", "install", "--yes", "python3.7"]

# CMD ["/bin/echo", "Hello World"] 
# CMD echo "Hello World" 

# ENV name Jon Snow

# ENTRYPOINT ["/bin/bash", "-c", "echo Hello, ${name}"]
ENTRYPOINT ["/bin/echo", "Hello"]
CMD ["World"]
