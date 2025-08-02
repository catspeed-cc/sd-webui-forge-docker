# secretsauce.sh - a script that is copied to the container to be executed via "docker exec" by end user to reinstall container(s) dependencies

# mooleshacat REMOVE BEFORE MERGE


#
##
## Install dependencies IF NOT ALREADY INSTALLED!
##
#

# change to work directory ("WD")
cd /app

# RATHER than implement extensive logic to only do the deps if they do not exist,
# we assume the user only runs init when initializing container, so we can just
# rm -r the directory and fetch it again. Quick,clean, simple
rm -r webui
# mooleshacat brb
git clone https://github.com/lllyasviel/stable-diffusion-webui-forge webui

# change into the webui dir
cd webui/

# pip install commands ALL ARE CHAINED TOGETHER BE CAREFUL EDITING THIS
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore -r requirements_versions.txt && \
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore joblib && \
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore --upgrade pip && \
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore --upgrade pip && \
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore "setuptools>=62.4"

mkdir -p /app/webui/repositories
cd /app/webui/repositories

# clobber all three repo dirs
rm -r stable-diffusion-webui-assets/ huggingface_guess/ BLIP/

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
git checkout 48211a1594f1321b00f14c9f7a5b4813144b2fb9 && \
sed -i 's/transformers==4\.15\.0/transformers==4.46.1/g' /app/webui/repositories/BLIP/requirements.txt && \
pip3 install --force-reinstall --no-deps --no-cache-dir --root-user-action ignore -r requirements.txt

# KEEP THIS FOR REFERENCE FOR IDIOT :)
# modules/launch_utils.py contains the repos and hashes
#assets_commit_hash = os.environ.get('ASSETS_COMMIT_HASH', "6f7db241d2f8ba7457bac5ca9753331f0c266917")
#huggingface_guess_commit_hash = os.environ.get('', "84826248b49bb7ca754c73293299c4d4e23a548d")
#blip_commit_hash = os.environ.get('BLIP_COMMIT_HASH', "48211a1594f1321b00f14c9f7a5b4813144b2fb9")


# mooleshacat REMOVE BEFORE MERGE
