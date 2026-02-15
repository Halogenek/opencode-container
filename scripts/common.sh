#!/usr/bin/env bash

set -e

# Run the container
run_container() {
    if [ -z "$IMAGE" ]; then
        echo "IMAGE is not set"
        exit 1
    fi

    # Create local opencode directories if they don't exist
    mkdir -p "$HOME/.local/share/opencode"
    mkdir -p "$HOME/.config/opencode"
    mkdir -p "$HOME/.local/state/opencode"

    docker run -it --rm \
        --name opencode \
        -e HOST_UID="$(id -u)" \
        -e HOST_GID="$(id -g)" \
        -v "$(pwd):/app" \
        -v "$HOME/.local/share/opencode:/home/opencode/.local/share/opencode" \
        -v "$HOME/.config/opencode:/home/opencode/.config/opencode" \
        -v "$HOME/.local/state/opencode:/home/opencode/.local/state/opencode" \
        "$IMAGE" \
        "${POSITIONAL_ARGS[@]}"
}
