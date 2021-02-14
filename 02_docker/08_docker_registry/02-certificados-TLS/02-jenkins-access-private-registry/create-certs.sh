#!/bin/bash

# Delete folder if exist
rm -rf registry-certs

# Create destination folder
mkdir -p registry-certs

# Create Certificate Authority
echo "Creating Certificate Authority"
echo -e '\n\n' | docker run --rm -i -v $PWD/registry-certs:/out squareup/certstrap init --common-name ca

# Create Certificate Sign Request for registry
echo "Creating Certificate Sign Request for registry.intranet"
echo -e '\n\n' | docker run --rm -i -v $PWD/registry-certs:/out squareup/certstrap request-cert -domain registry.intranet

# Sign CSR with Certificate Authority
echo "Creating registry.intranet certificate"
docker run --rm -it -v $PWD/registry-certs:/out squareup/certstrap sign registry.intranet --CA ca

# Create Certificate Sign Request for jenkins
echo "Creating Certificate Sign Request for jenkins.intranet"
echo -e '\n\n' | docker run --rm -i -v $PWD/registry-certs:/out squareup/certstrap request-cert -domain jenkins.intranet

# Sign CSR with Certificate Authority
echo "Creating jenkins.intranet certificate"
docker run --rm -it -v $PWD/registry-certs:/out squareup/certstrap sign jenkins.intranet --CA ca