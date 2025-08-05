#!/usr/bin/env bash

# docker-destroy-single-gpu-only.sh: stop & remove all sd-forge containers

echo "#"
echo "##"
echo "## sd-forge-webui-docker docker-destroy-single-gpu-only.sh script initiated"
echo "##"
echo "## this will destroy the docker container so you can recreate it"
echo "##"
echo "#"

# Source the shared functions
# Adjust path as needed: relative, absolute
source ./docker/lib/commonlib.sh

# simple destroy script
echo "Running `docker compose down`"
docker compose -f ${DOCKER_COMPOSE_DIR}/docker-compose.yaml -f ${DOCKER_COMPOSE_DIR}/docker-compose.single-gpu.nvidia.yaml down

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
