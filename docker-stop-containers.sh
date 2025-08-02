#!/usr/bin/env bash

# docker-stop-container.sh: stop all sd-forge containers

# Get the list of ALL containers `docker ps -a`
DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

# Loop through each container
while read container; do
    echo "Stopping docker container: $container"
    docker stop $container
done <<< "$DOCKER_PSA_LIST"

echo "docker ps -a output:"
docker ps -a

echo "Docker containers stopped."

