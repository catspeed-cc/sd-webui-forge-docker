#!/bin/bash

# start.sh - SD Forge launcher with debug fallback

set -euo pipefail  # Exit on error, undefined var, pipe failure

# GET RELATIVE AND ABSOLUTE PATH TO CURRENT SCRIPT

# NEW CODE BELOW

# Source the shared functions
# Adjust path as needed: relative, absolute, or via environment
source ./docker/lib/commonlib.sh

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

