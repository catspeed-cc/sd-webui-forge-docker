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

#
##
## Install dependencies IF NOT ALREADY INSTALLED!
##
#

# quick fix, tell bash we are handling errors (so do not exit) when we really are not xD
set +e  # disable exit-on-error

# change to work directory ("WD")
cd /app


# RATHER than implement extensive logic to only do the deps if they do not exist, 
# we assume the user only runs init when initializing container, so we can just
# rm -r the directory and fetch it again. Quick,clean, simple


# cant remove the webui directory to re-clone -- next best: `git pull origin main`
# this works because it does not touch the mounted /models and /outputs directories
# and there is no compilation needed (appears to be frontend stuff)
if [ ! -e "./webui" ]; then
  # mooleshacat brb
  git clone https://github.com/lllyasviel/stable-diffusion-webui-forge webui
  cd webui
else
  cd webui
  git pull origin main
fi

# pip install commands ALL ARE CHAINED TOGETHER BE CAREFUL EDITING THIS
#pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# INSTALL CUDA 12.8 LATEST VERSION - UPDATE TO 12.9 (cu129) when it ships
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# not erroring on success, but pre-emptive fix from below :)
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore -r requirements_versions.txt
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "⚠️ pip install failed with code $exit_code, but continuing..."
fi

pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore joblib
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore --upgrade pip && \
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore --upgrade pip && \
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore "setuptools>=62.4"

mkdir -p /app/webui/repositories
cd /app/webui/repositories

# clobber all three repo dirs
# I don't like the `-f` in production, but it supresses the errors and prevents container stop on startup
rm -rf stable-diffusion-webui-assets/ huggingface_guess/ BLIP/

# modules/launch_utils.py contains the repos and hashes
git clone --config core.filemode=false https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git && \
git clone --config core.filemode=false https://github.com/lllyasviel/huggingface_guess.git && \
git clone --config core.filemode=false https://github.com/salesforce/BLIP.git

# checkout the correct hashes

# sd-webui-assets
cd /app/webui/repositories/stable-diffusion-webui-assets && \
git checkout 6f7db241d2f8ba7457bac5ca9753331f0c266917

# huggingface_guess
cd /app/webui/repositories/huggingface_guess && \
git checkout 84826248b49bb7ca754c73293299c4d4e23a548d

#
# THERE IS A CONFLICT between the requirements.txt for BLIP and the upstream/main requirements.txt
#
# LIST OF CORRECTED CONFLICTS:
#
#                              `transformers==4.15.0`->`transformers==4.46.1` # 2025-08-02 @ 12-37 EST resolved by mooleshacat
#
cd /app/webui/repositories/BLIP && \
git checkout 48211a1594f1321b00f14c9f7a5b4813144b2fb9

sed -i 's/transformers==4\.15\.0/transformers==4.46.1/g' /app/webui/repositories/BLIP/requirements.txt

# fix to exit code (even on success) causing container to exit ...
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore -r requirements.txt
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "⚠️ pip install failed with code $exit_code, but continuing..."
fi

# change back to webui dir so we can launch `launch.py`
cd /app/webui

# KEEP THIS FOR REFERENCE FOR IDIOT :)
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

pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore typing-extensions packaging

#echo "sleep infinity for debug ..."
#exec sleep infinity

echo "STARTING THE PYTHON APP..."

# Run SD Forge with all passed arguments (no default so far)
# CONFIRMED --server-name=0.0.0.0 is safe as long as docker compose comments are respected / understood.
exec python3 -W "ignore::FutureWarning" -W "ignore::DeprecationWarning" launch.py --server-name=0.0.0.0${PYTHON_ADD_ARG} ${filtered_args[@]}

# If we get here, launch.py failed
echo "❌ SD Forge exited with code $?"
echo "💡 Debug shell available. Run: docker-compose exec CONTAINER_NAME bash"
echo "OR run \`docker compose down\` to stop the container" 
exec sleep infinity
