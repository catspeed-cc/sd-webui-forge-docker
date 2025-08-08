#!/bin/bash

# start.sh - SD Forge launcher with debug fallback

set -euo pipefail  # Exit on error, undefined var, pipe failure

# start out in the correct location
cd /app/webui

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

# Source the shared functions & configuration
source /app/webui/docker/lib/commonlib.sh

echo "#"
echo "##"
echo "## sd-forge-webui-docker startup script"
echo "##"
echo "## please grab some coffee, this will take some time on first run"
echo "##"
echo "#"

echo "🚀 Starting Stable Diffusion Forge..." >&2
echo "🔧 Args: $*" >&2

# re/install dependencies
re_install_deps "false"

# change back to webui dir so we can launch `launch.py`
# especially here, re_install_deps.sh may change it
cd /app/webui

# KEEP THIS FOR REFERENCE FOR IDIOT (@mooleshacat) :)
# modules/launch_utils.py contains the repos and hashes
#assets_commit_hash = os.environ.get('ASSETS_COMMIT_HASH', "6f7db241d2f8ba7457bac5ca9753331f0c266917")
#huggingface_guess_commit_hash = os.environ.get('', "84826248b49bb7ca754c73293299c4d4e23a548d")
#blip_commit_hash = os.environ.get('BLIP_COMMIT_HASH', "48211a1594f1321b00f14c9f7a5b4813144b2fb9")

# Example: incoming arguments
args=("$@")

# Array to hold filtered arguments
filtered_args=()

# Loop through all arguments
i=0
while [ $i -lt ${#args[@]} ]; do
  arg="${args[$i]}"

  # Check for --server-name=0.0.0.0 (combined form)
  if [[ "$arg" == "--server-name=0.0.0.0" ]]; then
    # Skip this argument (do not add to filtered_args)
    :
  # Check for --server-name followed by 0.0.0.0 (separate arguments)
  elif [[ "$arg" == "--server-name" ]]; then
    # Skip both --server-name and the next argument (assume it's 0.0.0.0)
    ((i++))  # Skip the value
  else
    # Keep the argument
    filtered_args+=("$arg")
  fi

  ((i++))
done

# Tell sd-forge to use cu121
export TORCH_INDEX_URL="https://download.pytorch.org/whl/cu121"
export TORCH_COMMAND="python -m pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url ${TORCH_INDEX_URL}"   

echo "STARTING THE PYTHON APP..."

# Run SD Forge with all passed arguments (no default so far)
# CONFIRMED --server-name=0.0.0.0 is safe as long as docker compose comments are respected / understood.
exec python3 -W "ignore::FutureWarning" -W "ignore::DeprecationWarning" launch.py --server-name=0.0.0.0${PYTHON_ADD_ARG} ${filtered_args[@]}

if [ "$FDEBUG" = true ]; then
  # This will be enabled by future debug flag
  # If we get here, launch.py failed
  echo "❌ SD Forge exited with code $?"
  echo "💡 Debug shell available. Run: docker-compose exec CONTAINER_NAME bash"
  echo "OR run \`docker-stop-containers.sh\` or \`docker-destroy-*.sh\` to stop the container" 
  exec sleep infinity
fi
