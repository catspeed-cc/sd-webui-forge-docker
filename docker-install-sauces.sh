#!/bin/bash

# start.sh - SD Forge launcher with debug fallback

# temporary needed
 # export GIT_ROOT=$(find_git_root)

# this installer and the `secretsauce.sh` script require this to function correctly. others do not.
set -euo pipefail  # Exit on error, undefined var, pipe failure

# GET RELATIVE AND ABSOLUTE PATH TO CURRENT SCRIPT

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

    # to be compatible with slim docker-compose/sauce only installs
    echo "Warn: falling back to non-git installation default"
    echo "      this is okay if you did a minimal/slim/custom install"

    # fallback: inside install and uninstall script we are in root
    echo "${PWD}"

    return 0
}

# Find the Git root
export GIT_ROOT=$(find_git_root)

echo "#"
echo "##"
echo "## sd-forge-webui-docker docker-install-sauces.sh script initiated"
echo "##"
echo "## installing all sauce scripts into PATH and ~/.bashrc"
echo "##"
echo "#"

# Source the shared functions
# Adjust path as needed: relative, absolute
source ${GIT_ROOT}/docker/lib/commonlib.sh

ADD_TO_PATH=${GIT_ROOT}/docker/sauce_scripts/

echo "[DEBUG] ADD_TO_PATH: [${ADD_TO_PATH}]"
echo "Current path: [${PATH}]"
NEW_PATH="\${PATH}:${ADD_TO_PATH}"
echo "Final path to add: [${NEW_PATH}]"

echo ""
echo "Scripts will only be accessible as user ${USER} (should be root, docker runs as root)"
echo ""
echo "This will write the new PATH and also add export to .bashrc to make it persist across shells and reboots. 'Y' to continue 'n' to exit."
echo ""
confirm_continue

export PATH=${NEW_PATH}

echo "# managed by sd-forge-webui-docker BEGIN" | tee -a ~/.bashrc
echo "export PATH=${NEW_PATH}" | tee -a ~/.bashrc
echo "# managed by sd-forge-webui-docker END" | tee -a ~/.bashrc

# Configure the GIT_ROOT (important, required)
find . -type f -name "*.sh" -print0 | xargs -0 sed -i "s|export GIT_ROOT=\$(find_git_root)|export GIT_ROOT=$GIT_ROOT|g"
