#!/usr/bin/env bash

# docker-start-containers.sh: start all sd-forge containers

# Get the list of ALL containers `docker ps -a`
DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

# Loop through each container
while read container; do
    echo "Starting docker container: $container"
    docker start $container
done <<< "$DOCKER_PSA_LIST"

echo "docker ps output"
docker ps

echo "Docker containers started."
