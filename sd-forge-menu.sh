#!/bin/bash

# docker-install-sauces.sh: add sauces to path & ~/.bashrc

# this installer and the `secretsauce.sh` script require this to function correctly. others do not.
set -euo pipefail  # Exit on error, undefined var, pipe failure

# Function to find the Git root directory, ascending up to 4 levels
# Required for source line to be accurate and work from all locations
find_root() {
    local current_dir="$(pwd)"
    local max_levels=6
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

    # to be compatible with slim docker-compose/sauce only installs
    echo ""
    echo "Warn: falling back to non-git installation default"
    echo "      this is okay if you did a minimal/slim/custom install"
    echo ""

    # Fallback: script directory or known path
    local fallback="${PWD}"  # or $(dirname "$0")/..
    if [ -d "$fallback" ]; then
      echo "$fallback"
      return 0  # ← Success!
    fi

    # if we reach here we failed - even the fallback failed somehow O_o
    return 1
}

# Find the Git root
export GIT_ROOT=$(find_root)

echo "#"
echo "##"
echo "## sd-forge-webui-docker sd-forge-menu.sh script initiated"
echo "##"
echo "## Providing menu to user for docker management"
echo "##"
echo "#"

# Source the shared functions & configuration
source ${GIT_ROOT}/docker/lib/commonlib.sh

sleep 3
clear
reset

# Navigate to the docker directory
cd "${GIT_ROOT}/docker" || { echo "Failed to enter docker directory"; exit 1; }

SCRIPT_DIR="./sauce_scripts"
WEBUI_SCRIPT_DIR="./sauce_scripts_baked_into_docker_image"

# Main menu function
show_menu() {
    clear
    echo "===================================="
    echo "    SD-Forge Docker Management Menu "
    echo "===================================="
    echo
    echo "🔧 Initialization & Setup"
    echo "  1) Initialize CPU-Only Container"
    echo "  2) Initialize Single-GPU Container (NVIDIA)"
    echo "  3) Initialize Multi-GPU Container (NVIDIA)"
    echo
    echo "📦 Container Management"
    echo "  4) Start All Containers"
    echo "  5) Stop All Containers"
    echo "  6) Reinstall Container Dependencies"
    echo
    echo "🗑️  Cleanup & Destroy"
    echo "  7) Destroy CPU-Only Container"
    echo "  8) Destroy Single-GPU Container"
    echo "  9) Destroy Multi-GPU Container"
    echo
    echo "🧩 Advanced & Maintenance"
    echo " 10) Install Additional Sauces"
    echo " 11) Uninstall Additional Sauces"
    echo
    echo "  Q) Quit"
    echo
    printf " Choose an option: "
}

# Main loop
while true; do
    show_menu
    read -r choice

    case "${choice,,}" in
        "q")
            echo
            echo "Exiting. Goodbye!"
            break
            ;;

        "1")
            echo
            echo "Initializing CPU-Only Container..."
            echo "----------------------------------------"
            if [[ -x "$SCRIPT_DIR/docker-init-cpu-only.sh" ]]; then
                "$SCRIPT_DIR/docker-init-cpu-only.sh"
            else
                echo "Error: docker-init-cpu-only.sh not found or not executable."
            fi
            read -p "Press Enter to continue..."
            ;;

        "2")
            echo
            echo "Initializing Single-GPU Container (NVIDIA)..."
            echo "----------------------------------------"
            if [[ -x "$SCRIPT_DIR/docker-init-single-gpu-only.sh" ]]; then
                "$SCRIPT_DIR/docker-init-single-gpu-only.sh"
            else
                echo "Error: docker-init-single-gpu-only.sh not found or not executable."
            fi
            read -p "Press Enter to continue..."
            ;;

        "3")
            echo
            echo "Initializing Multi-GPU Container (NVIDIA)..."
            echo "----------------------------------------"
            if [[ -x "$SCRIPT_DIR/docker-init-multi-gpu-only.sh" ]]; then
                "$SCRIPT_DIR/docker-init-multi-gpu-only.sh"
            else
                echo "Error: docker-init-multi-gpu-only.sh not found or not executable."
            fi
            read -p "Press Enter to continue..."
            ;;

        "4")
            echo
            echo "Starting All Containers..."
            echo "----------------------------------------"
            if [[ -x "$SCRIPT_DIR/docker-start-containers.sh" ]]; then
                "$SCRIPT_DIR/docker-start-containers.sh"
            else
                echo "Error: docker-start-containers.sh not found or not executable."
            fi
            read -p "Press Enter to continue..."
            ;;

        "5")
            echo
            echo "Stopping All Containers..."
            echo "----------------------------------------"
            if [[ -x "$SCRIPT_DIR/docker-stop-containers.sh" ]]; then
                "$SCRIPT_DIR/docker-stop-containers.sh"
            else
                echo "Error: docker-stop-containers.sh not found or not executable."
            fi
            read -p "Press Enter to continue..."
            ;;

        "6")
            echo
            echo "Reinstalling Container Dependencies..."
            echo "----------------------------------------"
            if [[ -x "$SCRIPT_DIR/docker-reinstall-container-deps.sh" ]]; then
                "$SCRIPT_DIR/docker-reinstall-container-deps.sh"
            else
                echo "Error: docker-reinstall-container-deps.sh not found or not executable."
            fi
            read -p "Press Enter to continue..."
            ;;

        "7")
            echo
            echo "Destroying CPU-Only Container..."
            echo "----------------------------------------"
            if [[ -x "$SCRIPT_DIR/docker-destroy-cpu-only.sh" ]]; then
                "$SCRIPT_DIR/docker-destroy-cpu-only.sh"
            else
                echo "Error: docker-destroy-cpu-only.sh not found or not executable."
            fi
            read -p "Press Enter to continue..."
            ;;

        "8")
            echo
            echo "Destroying Single-GPU Container..."
            echo "----------------------------------------"
            if [[ -x "$SCRIPT_DIR/docker-destroy-single-gpu-only.sh" ]]; then
                "$SCRIPT_DIR/docker   




























