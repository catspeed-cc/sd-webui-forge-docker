#!/usr/bin/env bash

# secretsauce.sh - a script that is copied to the container to be executed via "docker exec" by end user to reinstall container(s) dependencies

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



# END OF FILE
