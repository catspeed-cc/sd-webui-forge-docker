#!/bin/bash

# docker-install-sauces.sh: add sauces to path & ~/.bashrc

# this installer and the `secretsauce.sh` script require this to function correctly. others do not.
set -euo pipefail  # Exit on error, undefined var, pipe failure

# Function to find the Git root directory, ascending up to 4 levels
# Required for source line to be accurate and work from all locations
find_root() {
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
    echo ""
    echo "Warn: falling back to non-git installation default"
    echo "      this is okay if you did a minimal/slim/custom install"
    echo ""

    # Fallback: script directory or known path
    local fallback="${PWD}"  # or $(dirname "$0")/..
    if [ -d "$fallback" ]; then
      echo "$fallback"
      return 0  # ← Success!
    fi

    # if we reach here we failed - even the fallback failed somehow O_o
    return 1
}

# Find the Git root
export GIT_ROOT=$(find_root)

echo "#"
echo "##"
echo "## sd-forge-webui-docker docker-install-sauces.sh script initiated"
echo "##"
echo "## installing all sauce scripts into PATH and ~/.bashrc"
echo "##"
echo "#"

# Source the shared functions & configuration
source ${GIT_ROOT}/docker/lib/commonlib.sh

# determine if cuda exists in the path - if not add it
if [[ ":$PATH:" == *":/usr/local/cuda/bin"* ]]; then
    echo "CUDA path is already in PATH"
    export NEW_PATH="\${PATH}:/usr/local/cuda/bin"
    export NEW_PATH_EXPANDED="${PATH}:/usr/local/cuda/bin"
fi

# Ether way we add ADD_T__PATH
export NEW_PATH="${NEW_PATH}:${GIT_ROOT}/docker/sauce_scripts/"
export NEW_PATH="${PATH}:${NEW_PATH}:${GIT_ROOT}/docker/sauce_scripts/"

if [ "$FDEBUG}" = "true" ]; then
  echo "Current path: [${PATH}]"
  echo "New path: [${NEW_PATH}]"
  echo "New path expanded: [${NEW_PATH_EXPANDED}]"
fi

# Check if already installed
IS_INSTALLED=$(grep -c "# managed by sd-forge-webui-docker" ~/.bashrc)

if [ "$FDEBUG}" = "true" ]; then
  # Show exactly what matches
  echo "DEBUG: Matching lines in ~/.bashrc:"
  grep "# managed by sd-forge-webui-docker" ~/.bashrc || echo "  → No matches found"
fi

if (( IS_INSTALLED > 0 )); then
  echo ""
  echo "Warn: Already installed (scripts already in PATH). Refusing to install again."
  echo "Run '/docker-uninstall-sauces.sh' first if you want to reinstall."
  echo ""
  exit 0
fi

#echo ""
echo "Scripts will only be accessible as user ${USER} (should be root, docker runs as root)"
echo ""
echo "This will write the new PATH and also add export to .bashrc to make it persist across shells and reboots. 'Y' to continue 'n' to exit."
echo ""
confirm_continue



# Function to update FDEBUG in target files
update_fdebug() {
  local value=$1
  find ./docker/lib -type f -name "commonlib.sh" -print0 | xargs -0 sed -i "s|export FDEBUG=[a-zA-Z0-9._]*|export FDEBUG=$value|g"
  echo "FDEBUG set to $value in matching files."
}

echo ""

# Default to 'n' if empty input
REPLY=${REPLY:-n}

while true; do
  read -p "Do you want to enable DEBUG mode? [N/y]: " -n 1 -r
  echo ""

  # Default to 'n' if empty
  REPLY=${REPLY:-n}

  # Check if input is valid (y/Y/n/N)
  if [[ $REPLY =~ ^[YyNn]$ ]]; then
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      FDEBUG=true
      echo "Enabling DEBUG mode..."
      update_fdebug true
    else
      FDEBUG=false
      echo "Disabling DEBUG mode (default)..."
      update_fdebug false
    fi
    break  # Valid input, exit loop
  else
    # Invalid input, prompt again
    echo "Please answer 'y' or 'n'."
  fi
done

# echo the path to the .bashrc
{
  echo "# managed by sd-forge-webui-docker BEGIN"
  echo "export PATH=${NEW_PATH}"
  echo "# managed by sd-forge-webui-docker END"
} | tee -a ~/.bashrc > /dev/null

# this is why we need the fully expanded path, to set the PATH :)
export PATH=${NEW_PATH_EXPANDED}

# Configure the GIT_ROOT (important, required)
#find ./docker -type f -name "*.sh" -print0 | xargs -0 sed -i "s|export GIT_ROOT=\$(find_git_root)|export GIT_ROOT=$GIT_ROOT|g"
echo "export GIT_ROOT=$GIT_ROOT" tee -a ${GIT_ROOT}/docker/lib/commoncfg.sh

# source the modified ~/.bashrc
source ~/.bashrc

echo ""
echo "Installation completed. Please see available scripts by typing 'docker-' and pressing tab"
echo ""
echo "Alternatively, read the documentation (README.md)"
echo ""
