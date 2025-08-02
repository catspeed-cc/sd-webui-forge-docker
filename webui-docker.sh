#!/bin/bash
# start.sh - SD Forge launcher with debug fallback
set -euo pipefail  # Exit on error, undefined var, pipe failure

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

# Now use filtered_args instead of original args
# Example: exec your command
# exec python app.py "${filtered_args[@]}"

# For debugging: print filtered args
printf "[DEBUG] Filtered args: '%s'\n" "${filtered_args[@]}"

# TORCH TEST (DEBUG, it failed when GPU bind worked... Remove?)
#echo ""
#echo "TORCH:"
#python3 -c "import torch; print(f'Torch: {torch.__version__}'); print(f'CUDA available: {torch.cuda.is_available()}'); print(f'CUDA version: {torch.version.cuda}');"

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

echo "STARTING THE PYTHON APP..."

# Run SD Forge with all passed arguments (no default so far)
# CONFIRMED --server-name=0.0.0.0 is safe as long as docker compose comments are respected / understood.
exec python3 -W "ignore::FutureWarning" -W "ignore::DeprecationWarning" launch.py --server-name=0.0.0.0${PYTHON_ADD_ARG} ${filtered_args[@]}

# If we get here, launch.py failed
echo "❌ SD Forge exited with code $?"
echo "💡 Debug shell available. Run: docker-compose exec CONTAINER_NAME bash"
echo "OR run \`docker compose down\` to stop the container" 
exec sleep infinity
