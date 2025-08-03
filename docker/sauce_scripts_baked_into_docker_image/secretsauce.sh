  GNU nano 7.2                                                                  webui-docker.sh
#!/usr/bin/env bash

# secretsauce.sh - a script that is copied to the container to be executed via "docker exec" by end user to reinstall container(s) dependencies

set -euo pipefail  # Exit on error, undefined var, pipe failure

# GET RELATIVE AND ABSOLUTE PATH TO CURRENT SCRIPT

# NEW CODE BELOW

# Source the shared functions
# Adjust path as needed: relative, absolute, or via environment
source ../lib/commonlib.sh

echo "#"
echo "##"
echo "## sd-forge-webui-docker startup script"
echo "##"
echo "## please grab some coffee, this will take some time on first run"
echo "##"
echo "#"


# Initialize all path variables
init_script_paths

# NEW CODE ABOVE

echo ""
# Debug: show paths
echo "📘 Script name: $SCRIPT_NAME"
echo "📁 Absolute script path: $ABS_SCRIPT_PATH"
echo "🔗 Relative script path: $REL_SCRIPT_PATH"
echo "📁 Absolute dir: $ABS_SCRIPT_DIR"
echo "🔗 Relative dir: $REL_SCRIPT_DIR"
echo "💻 Running from: $PWD"
echo ""
echo ""

# NEW CODE ABOVE

echo "🚀 Starting Stable Diffusion Forge..." >&2
echo "🔧 Args: $*" >&2

#echo "==================="

# DEBUG !
#env | grep -E "(CUDA|NVIDIA|SD_GPU)" >&2

#echo "==================="

# Debug: Show all relevant env vars
echo "🔍 SD_GPU_DEVICE: '$SD_GPU_DEVICE'" >&2
echo "🔍 NVIDIA_VISIBLE_DEVICES: '$NVIDIA_VISIBLE_DEVICES'" >&2
echo "🔍 CUDA_DEVICE_ORDER: '$CUDA_DEVICE_ORDER'" >&2

# Set CUDA_VISIBLE_DEVICES from safe source
export CUDA_VISIBLE_DEVICES=${SD_GPU_DEVICE}
echo "🔧 CUDA_VISIBLE_DEVICES: $CUDA_VISIBLE_DEVICES" >&2

# 🔍 CRITICAL DEBUG: Verify GPU access before launching Python (KEEP in production! user debug)
echo "🔍 Running nvidia-smi..." >&2
if command -v nvidia-smi >/dev/null; then
  nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv >&2 || true
else
  echo "⚠️  nvidia-smi not found!" >&2
fi

# NEW CODE BELOW

# install dependencies
re_install_deps

# NEW CODE ABOVE

# change back to webui dir (good practice)
cd /app/webui

# stop container
../sauce_scripts/docker-stop-containers.sh

# start container
../sauce_scripts/docker-start-containers.sh

# END OF FILE
