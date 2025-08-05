#!/bin/bash

# start.sh - SD Forge launcher with debug fallback

set -euo pipefail  # Exit on error, undefined var, pipe failure

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
export GIT_ROOT=/root/sd-forge
if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "#"
echo "##"
echo "## sd-forge-webui-docker docker-uninstall-sauces.sh script initiated"
echo "##"
echo "## UNinstalling all sauce scripts from PATH and ~/.bashrc"
echo "##"
echo "#"

# Source the shared functions
# Adjust path as needed: relative, absolute
source ${GIT_ROOT}/docker/lib/commonlib.sh

ADD_TO_PATH=${GIT_ROOT}/docker/sauce_scripts/

if [ "$FDEBUG" = true ]; then
  echo "[DEBUG] ADD_TO_PATH: [${ADD_TO_PATH}]"
  echo "Current path: [${PATH}]"
fi
NEW_PATH="${PATH}:${ADD_TO_PATH}"
if [ "$FDEBUG" = true ]; then
  echo "Final path to add: [${NEW_PATH}]"
fi

echo ""
echo "This will remove the sauce scripts from the PATH and ~/.bashrc. 'Y' to continue 'n' to exit."
echo ""
confirm_continue

# Escape NEW_PATH for safe use in sed (escape . * + ? ^ $ [] $$
escape_for_sed() {
  echo "$1" | sed 's/[.[\*^$()+?{|]/\\&/g'
}

export NEW_PATH_ESCAPED=$(escape_for_sed "$NEW_PATH")

# Remove lines that contain the path (more robust)
sed -i '/# managed by sd-forge-webui-docker BEGIN/,/# managed by sd-forge-webui-docker END/d' ~/.bashrc

# Update current session's PATH (remove the entry)
export PATH=$(echo ":$PATH:" | sed -E "s#:${NEW_PATH}:#:#g" | sed 's#^:##; s#:$##')

echo "Uninstalled: $NEW_PATH removed from PATH and ~/.bashrc"
