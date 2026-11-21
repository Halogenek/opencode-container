#!/usr/bin/env bash

set -e

PROJECT_DIR_NAME=$(basename "$PWD")
# Docker container names can only contain [a-zA-Z0-9_.-]
SANITIZED_PROJECT_NAME=$(echo "$PROJECT_DIR_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_.-]/_/g')
CONTAINER_NAME="opencode-${SANITIZED_PROJECT_NAME}"

IMAGE="${IMAGE:="opencode:local"}"

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "${SCRIPT_DIR}"/scripts/common.sh

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [-- OPENCODE_ARGS...]

Run the OpenCode container. The image is rebuilt on every run using Docker layer caching.

OPTIONS:
    -b              Force a clean rebuild of the OpenCode image (disables layer cache)
    -i IMAGE        Use specified Docker image name (default: opencode:local)
    -h              Show this help message and exit

ARGUMENTS AFTER '--':
    All arguments after '--' are forwarded to opencode without interpretation.
    This allows passing options to opencode that would otherwise be interpreted
    by this script (e.g., -b, -h).

EXAMPLES:
    $(basename "$0")                        # Run the container (rebuild with cache)
    $(basename "$0") -b                     # Clean rebuild and run the container
    $(basename "$0") -i myimage:latest      # Use custom image name
    $(basename "$0") -- --version           # Pass --version to opencode
    $(basename "$0") -b -- --help           # Clean rebuild, then pass --help to opencode
    $(basename "$0") -i "ghcr.io/european-epc-competence-center/opencode-container:main" -b        # Use the github image instead of the local one

EOF
}

parse_args() {
    FORCE_BUILD=false
    POSITIONAL_ARGS=()

    # Parse arguments manually to properly handle '--' separator
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --)
            # Everything after '--' goes to positional args (forwarded to opencode)
            shift
            POSITIONAL_ARGS+=("$@")
            break
            ;;
        -b)
            FORCE_BUILD=true
            shift
            ;;
        -i)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: -i requires an image name argument" >&2
                show_help
                exit 1
            fi
            IMAGE="$2"
            shift 2
            ;;
        -h)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: Invalid option $1" >&2
            show_help
            exit 1
            ;;
        *)
            # Non-option argument
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
        esac
    done
}

build_image() {
    local force_build=$1

    echo "Building opencode image..."
    echo "Build directory: $SCRIPT_DIR"

    # Always build; Docker layer caching keeps unchanged builds cheap.
    # Force a clean rebuild when requested.
    if [ "$force_build" = true ]; then
        echo "Force rebuilding opencode image without cache..."
        DOCKER_BUILDKIT=1 docker build --no-cache --progress=plain -t "$IMAGE" "$SCRIPT_DIR"
    else
        DOCKER_BUILDKIT=1 docker build --progress=plain -t "$IMAGE" "$SCRIPT_DIR"
    fi
}

main() {
    parse_args "$@"
    build_image "$FORCE_BUILD"
    run_container
}

main "$@"
