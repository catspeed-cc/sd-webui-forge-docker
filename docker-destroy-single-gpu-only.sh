#!/usr/bin/env bash

# docker-destroy-single-gpu-only.sh: stop & remove all sd-forge containers

# simple destroy script
echo "Running `docker compose down`"
docker compose -f docker-compose.yaml -f docker-compose.single-gpu.nvidia.yaml down

# Get the list of ALL containers `docker ps -a`
DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

# Loop through each container
while read container; do
    echo "Stopping docker container: $container"
    docker stop $container
    echo "Removing docker container: $container"
    docker rm $container
done <<< "$DOCKER_PSA_LIST"

echo "docker ps -a output:"
docker ps -a

echo ""
echo "Docker containers stopped & removed."
echo ""
