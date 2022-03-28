#!/bin/bash

set -e

# Read required variables
readonly imageName="${IMAGE_NAME:?'Missing variable'}"
readonly containerName="${CONTAINER_NAME:?'Missing variable'}"
readonly appPort="${APP_PORT:?'Missing variable'}"

# Stop running container
docker stop $containerName 2>/dev/null || true

# Remove container
docker rm $containerName 2>/dev/null || true

# Remove image
docker rmi $imageName 2>/dev/null || true

# Run container
docker run -d --name $containerName -e PORT=$appPort -p $appPort:$appPort $imageName
