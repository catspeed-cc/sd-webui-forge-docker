#!/usr/bin/env bash

# docker-destroy-multi-gpu-only.sh: stop & remove all sd-forge containers

# Function to find the Git root directory, ascending up to 4 levels
# Required for source line to be accurate and work from all locations
find_git_root() {
    local current_dir="$(pwd)"
    local max_levels=6
    local level=0
    local dir="$current_dir"

    while [[ $level -le $max_levels ]]; do
        if [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        # Go up one level
        dir="$(dirname "$dir")"
        # If we've reached the root (e.g., /), stop early
        if [[ "$dir" == "/" ]] || [[ "$dir" == "//" ]]; then
            break
        fi
        ((level++))
    done

    echo "Error: .git directory not found within $max_levels parent directories." >&2
    return 1
}

# Find the Git root
export GIT_ROOT=/root/sd-forge
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "#"
echo "##"
echo "## sd-forge-webui-docker docker-destroy-multi-gpu-only.sh script initiated"
echo "##"
echo "## this will destroy the docker container so you can recreate it"
echo "##"
echo "#"

# Source the shared functions
source ${GIT_ROOT}/docker/lib/commonlib.sh

# simple destroy script
echo "Running `docker compose down`"
docker compose -f ${DOCKER_COMPOSE_DIR}/docker-compose.cpu.yaml -f ${DOCKER_COMPOSE_DIR}/docker-compose.multi-gpu.nvidia.yaml down

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
