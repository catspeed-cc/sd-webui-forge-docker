#!/usr/bin/env bash

# docker-stop-container.sh: stop all sd-forge containers

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
echo "## sd-forge-webui-docker docker-stop-containers.sh script initiated"
echo "##"
echo "## this will stop the container"
echo "##"
echo "#"

# Source the shared functions
source ${GIT_ROOT}/docker/lib/commonlib.sh

# Get the list of ALL containers `docker ps -a`
DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

# Loop through each container
while read container; do
  echo "Stopping docker container: $container"
  docker stop $container
  # If this is a custom/cutdown install, start only one container
  if [[ "$IS_CUSTOM_OR_CUTDOWN_INSTALL" == "true" ]]; then
    echo "Custom/cutdown install detected: started only one container."
    break
  fi
done <<< "$DOCKER_PSA_LIST"

echo "docker ps -a output:"
docker ps -a

echo "Docker containers stopped."

