#
##
## Import common functions and startup routines
##
#

re_install_deps() {

  #
  ##
  ## Install dependencies IF NOT ALREADY INSTALLED!
  ##
  ## The `webui-docker.sh` and `secretsauce.sh` are run inside the container (baked into docker image)
  ##
  #

  # quick fix, tell bash we are handling errors (so do not exit) when we really are not xD
  set +e  # disable exit-on-error

  # change to work directory ("WD")
  cd /app


  # RATHER than implement extensive logic to only do the deps if they do not exist,
  # we assume the user only runs init when initializing container, so we can just
  # rm -r the directory and fetch it again. Quick,clean, simple
  #
  # Or perhaps they ran the `docker-reinstall-container-deps.sh` which `docker
  # exec'd` the `secretsauce.sh` on running container
  #
  # cant remove the webui directory to re-clone -- next best: `git pull origin main`
  # this works because it does not touch the mounted /models and /outputs directories
  # and there is no compilation needed (appears to be frontend stuff)
  if [ ! -e "./webui" ]; then
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

}

# Function to find the Git root directory, ascending up to 4 levels
find_git_root() {
    local current_dir="$(pwd)"
    local max_levels=4
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

# init_script_paths.sh - Portable script path initialization
init_script_paths() {
    local abs_path
    abs_path=$(readlink -f "$0") || {
        echo "❌ Error: Cannot resolve script path. Is 'readlink -f' supported?" >&2
        return 1
    }

    # Export absolute components
    export ABS_SCRIPT_PATH="$abs_path"
    export ABS_SCRIPT_DIR="$(dirname "$abs_path")"
    export SCRIPT_NAME="$(basename "$abs_path")"

    # Compute REL_SCRIPT_DIR (relative to current working directory)
    local rel_dir=""
    if rel_dir=$(realpath --relative-to="$PWD" "$ABS_SCRIPT_DIR" 2>/dev/null); then
        export REL_SCRIPT_DIR="$rel_dir"
    elif command -v python3 >/dev/null 2>&1; then
        export REL_SCRIPT_DIR="$(
            python3 -c "import os; print(os.path.relpath('$ABS_SCRIPT_DIR', '$PWD'))"
        )"
    else
        # Fallback: basic relative logic
        if [[ "$ABS_SCRIPT_DIR" == "$PWD" ]]; then
            export REL_SCRIPT_DIR="."
        elif [[ "$ABS_SCRIPT_DIR" == "$PWD"/* ]]; then
            export REL_SCRIPT_DIR="./${ABS_SCRIPT_DIR#$PWD/}"
        else
            export REL_SCRIPT_DIR="$ABS_SCRIPT_DIR"
        fi
    fi

    # Build full relative script path
    export REL_SCRIPT_PATH="$REL_SCRIPT_DIR/$SCRIPT_NAME"
}

confirm_continue() {
    while true; do
        read -p "Do you want to continue? [Y/n]: " -r REPLY
        REPLY=${REPLY:-y}

        case "$REPLY" in
            [Yy]) break ;;
            [Nn]) echo "Exiting..."; exit 0 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

#
##
## COMMON initialization
##
#

# Find the Git root
GIT_ROOT=$(find_git_root)
if [[ $? -ne 0 ]]; then
    exit 1
fi

# self-initialize, otherwise errors and empty variables below
init_script_paths

echo ""
echo "Initializing ..."
echo ""
# Now you can use GIT_ROOT in your script
echo "Git root found at: $GIT_ROOT"

echo ""
# Debug: show paths
echo "📘 Script name: $SCRIPT_NAME"
echo "📁 Absolute script path: $ABS_SCRIPT_PATH"
echo "🔗 Relative script path: $REL_SCRIPT_PATH"
echo "📁 Absolute dir: $ABS_SCRIPT_DIR"
echo "🔗 Relative dir: $REL_SCRIPT_DIR"
echo "💻 Running from: $PWD"
echo ""
