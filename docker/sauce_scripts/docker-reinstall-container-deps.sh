#!/usr/bin/env bash

# docker-reinstall-container-deps.sh

# docker exec the sauce!
# Get the list of ALL containers `docker ps -a`
DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

# Loop through each container
while read container; do
    echo "Reinstalling deps on docker container: $container"
    docker exec ${container} /app/webui/docker/secret_sauce_baked_into_docker_image/secretsauce.sh
done <<< "$DOCKER_PSA_LIST"

/app/webui/docker/secret_sauce/docker-stop-containers.sh
/app/webui/docker/secret_sauce/docker-start-containers.sh

echo ""
echo "all containers have reinstalled their dependencies"
echo ""


