  GNU nano 7.2                                                                  webui-docker.sh
#!/usr/bin/env bash

# secretsauce.sh - a script that is copied to the container to be executed via "docker exec" by end user to reinstall container(s) dependencies

# this installer and the `secretsauce.sh` script require this to function correctly. others do not.
set -euo pipefail  # Exit on error, undefined var, pipe failure

# Source the shared functions & configuration
source /app/webui/lib/commonlib.sh

echo "#"
echo "##"
echo "## sd-forge-webui-docker secretsauce script"
echo "##"
echo "## reinstalling all possible dependencies while container is running"
echo "## please grab some coffee, this will take some time on first run"
echo "##"
echo "#"

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

echo "🚀 Starting Stable Diffusion Forge..." >&2
echo "🔧 Args: $*" >&2

# install dependencies
re_install_deps "true"

# change back to webui dir (good practice)
cd /app/webui
