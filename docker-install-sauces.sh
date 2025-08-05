#!/bin/bash

# start.sh - SD Forge launcher with debug fallback

set -euo pipefail  # Exit on error, undefined var, pipe failure

# GET RELATIVE AND ABSOLUTE PATH TO CURRENT SCRIPT

echo "#"
echo "##"
echo "## sd-forge-webui-docker docker-install-sauces.sh script initiated"
echo "##"
echo "## installing all sauce scripts into PATH and ~/.bashrc"
echo "##"
echo "#"

# Source the shared functions
# Adjust path as needed: relative, absolute
source ./docker/lib/commonlib.sh

ADD_TO_PATH=${GIT_ROOT}/docker/sauce_scripts/

echo "[DEBUG] ADD_TO_PATH: [${ADD_TO_PATH}]"
echo "Current path: [${PATH}]"
NEW_PATH="\${PATH}:${ADD_TO_PATH}"
echo "Final path to add: [${NEW_PATH}]"

echo ""
echo "Scripts will only be accessible as user ${USER} (should be root, docker runs as root)"
echo ""
echo "This will write the new PATH and also add export to .bashrc to make it persist across shells and reboots. 'Y' to continue 'n' to exit."
echo ""
confirm_continue

export PATH=${NEW_PATH}

echo "# managed by sd-forge-webui-docker BEGIN" | tee -a ~/.bashrc
echo "export PATH=${NEW_PATH}" | tee -a ~/.bashrc
echo "# managed by sd-forge-webui-docker END" | tee -a ~/.bashrc
