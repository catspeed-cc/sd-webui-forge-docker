#!/bin/bash

# start.sh - SD Forge launcher with debug fallback

set -euo pipefail  # Exit on error, undefined var, pipe failure

# start out in the correct location
cd /app/webui

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
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Source the shared functions directly only in container scripts
source /app/webui/lib/commonlib.sh

echo "#"
echo "##"
echo "## sd-forge-webui-docker startup script"
echo "##"
echo "## please grab some coffee, this will take some time on first run"
echo "##"
echo "#"

echo "🚀 Starting Stable Diffusion Forge..." >&2
echo "🔧 Args: $*" >&2

if [ "$FDEBUG" = true ]; then
  # DEBUG but keep disabled for now... will make debug flag in future update
  echo "==================="
  env | grep -E "(CUDA|NVIDIA|SD_GPU)" >&2
  echo "==================="

# Always show GPU info so user can adjust their config
echo "🔍 SD_GPU_DEVICE: '$SD_GPU_DEVICE'" >&2
if [ "$FDEBUG" = true ]; then
  # debug gate, this one might confuse the end user ("I thought I picked X not 0")
  echo "🔍 NVIDIA_VISIBLE_DEVICES: '$NVIDIA_VISIBLE_DEVICES'" >&2
fi
echo "🔍 CUDA_DEVICE_ORDER: '$CUDA_DEVICE_ORDER'" >&2

export CUDA_VISIBLE_DEVICES=${SD_GPU_DEVICE}
if [ "$FDEBUG" = true ]; then
  # Set CUDA_VISIBLE_DEVICES from safe source
  echo "🔧 CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES" >&2
fi

# 🔍 CRITICAL DEBUG: Verify GPU access before launching Python (KEEP in production! user debug)
#    No debug gate, extremely helpful when debugging problems w/ config :)
echo "🔍 Running nvidia-smi..." >&2
if command -v nvidia-smi >/dev/null; then
  nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv >&2 || true
else
  echo "⚠️  nvidia-smi not found!" >&2
fi

# re/install dependencies
re_install_deps

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

if [ "$FDEBUG" = true ]; then
  # For debugging: print filtered args
  printf "[DEBUG] Filtered args: '%s'\n" "${filtered_args[@]}"

  # TORCH TEST (DEBUG, it failed when GPU bind worked... Remove?)
  echo ""
  echo "TORCH:"
  python3 -c "import torch; print(f'Torch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}');"
fi

## FIX TO PROBLEM! Ensure we use the ENV var now if it is set, and pass --gpu-device-id=0
## ONLY IF IT IS SET !!!!

# Set CUDA_VISIBLE_DEVICES from safe source
if [[ -n "${SD_GPU_DEVICE:-}" ]]; then
  PYTHON_ADD_ARG=" --gpu-device-id=${SD_GPU_DEVICE}"
  echo "🔧 Will pass GPU arg:${PYTHON_ADD_ARG}" >&2
else
  echo "⚠️  WARNING: SD_GPU_DEVICE not set. Running on CPU or default GPU." >&2
  PYTHON_ADD_ARG=""
fi

pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore typing-extensions packaging

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
