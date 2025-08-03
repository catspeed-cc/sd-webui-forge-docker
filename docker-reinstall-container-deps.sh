#!/usr/bin/env bash

# docker-reinstall-container-deps.sh

# docker exec the sauce!
# Get the list of ALL containers `docker ps -a`
DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

# Loop through each container
while read container; do
    echo "Reinstalling deps on docker container: $container"
    docker exec ${container} /app/sauces/secretsauce.sh
done <<< "$DOCKER_PSA_LIST"

./docker-stop-containers.sh
./docker-start-containers.sh

echo ""
echo "all containers have reinstalled their dependencies"
echo ""


