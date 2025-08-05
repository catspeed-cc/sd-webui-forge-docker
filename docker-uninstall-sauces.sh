#!/bin/bash

# start.sh - SD Forge launcher with debug fallback

set -euo pipefail  # Exit on error, undefined var, pipe failure

# GET RELATIVE AND ABSOLUTE PATH TO CURRENT SCRIPT

echo "#"
echo "##"
echo "## sd-forge-webui-docker docker-uninstall-sauces.sh script initiated"
echo "##"
echo "## UNinstalling all sauce scripts from PATH and ~/.bashrc"
echo "##"
echo "#"

# Source the shared functions
# Adjust path as needed: relative, absolute
source ./docker/lib/commonlib.sh

ADD_TO_PATH=${GIT_ROOT}/docker/sauce_scripts/

echo "[DEBUG] ADD_TO_PATH: [${ADD_TO_PATH}]"
echo "Current path: [${PATH}]"
NEW_PATH="${PATH}:${ADD_TO_PATH}"
echo "Final path to add: [${NEW_PATH}]"

echo ""
echo "This will remove the sauce scripts from the PATH and ~/.bashrc. 'Y' to continue 'n' to exit."
echo ""
confirm_continue

# Remove lines that contain the path (more robust)
sed -i '/# managed by sd-forge-webui-docker BEGIN/,/# managed by sd-forge-webui-docker END/d' ~/.bashrc   

# Update current session's PATH (remove the entry)
export PATH=$(echo "$PATH" | sed -E "s|:${NEW_PATH}||g; s|${NEW_PATH}(:|$)||g; s|^:||; s|:$||")

echo "Uninstalled: $NEW_PATH removed from PATH and ~/.bashrc"
