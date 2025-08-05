#!/usr/bin/env bash

# docker-init-single-gpu-only.sh: create and start container for single GPU only

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
echo "## sd-forge-webui-docker docker-destroy-single-gpu-only.sh script initiated"
echo "##"
echo "## this will create the docker container for machine with 1 GPU only"
echo "##"
echo "#"

# Source the shared functions
source ${GIT_ROOT}/docker/lib/commonlib.sh

# simple init but there is config in related docker-compose file(s)
docker compose -f ${DOCKER_COMPOSE_DIR}/docker-compose.cpu.yaml -f ${DOCKER_COMPOSE_DIR}/docker-compose.single-gpu.nvidia.yaml up -d
