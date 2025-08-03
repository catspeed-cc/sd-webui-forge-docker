#
##
## Import common functions and startup routines
##
#

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


#
##
## COMMON initialization
##
#


# Debug: show paths
echo "📘 Script name: $SCRIPT_NAME"
echo "📁 Absolute script path: $ABS_SCRIPT_PATH"
echo "🔗 Relative script path: $REL_SCRIPT_PATH"
echo "📁 Absolute dir: $ABS_SCRIPT_DIR"
echo "🔗 Relative dir: $REL_SCRIPT_DIR"
echo "💻 Running from: $PWD"
