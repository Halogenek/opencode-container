#!/usr/bin/env bash

# Configure user to match host user UID/GID to avoid permission issues
# This function runs as root and updates the opencode user's UID/GID
configure_user() {
    local host_uid=${HOST_UID:-1000}
    local host_gid=${HOST_GID:-1000}

    # Get current UID/GID of opencode user
    local current_uid
    local current_gid
    current_uid=$(id -u opencode)
    current_gid=$(id -g opencode)

    echo "Current UID: $current_uid, Current GID: $current_gid"
    echo "Host UID: $host_uid, Host GID: $host_gid"

    # Only update if different from current values
    if [ "$current_uid" != "$host_uid" ] || [ "$current_gid" != "$host_gid" ]; then
        echo "Configuring container user to match host user (UID: $host_uid, GID: $host_gid)..."
        groupmod -g "$host_gid" opencode
        usermod -u "$host_uid" -g "$host_gid" opencode
    fi
    # Fix ownership of home directory
    chown -R opencode:opencode /home/opencode
}

check_config() {
    if [ ! -f ~/.local/share/opencode/auth.json ]; then
        echo "Auth file not found."
        mkdir -p ~/.local/share/opencode
        echo "Running standard OpenCode authentication..."
        opencode auth login
    else
        echo "Auth file already exists."
    fi
}

# Configure passwordless sudo for the opencode user
# This function runs as root and ensures sudoers configuration exists
configure_sudoers() {
    local sudoers_file="/etc/sudoers.d/opencode"

    echo "Ensuring passwordless sudo for opencode user..."

    # Create sudoers.d file if it doesn't exist
    if [ ! -f "$sudoers_file" ]; then
        echo "opencode ALL=(ALL) NOPASSWD:ALL" > "$sudoers_file"
        chmod 0440 "$sudoers_file"
        echo "Sudoers configuration created."
    else
        echo "Sudoers configuration already exists."
    fi
}

change_user_if_necessary() {
    # Check if we're running as the opencode user
    if [ "$(whoami)" != "opencode" ]; then
        echo "Running as root - configure user and re-exec as opencode user"
        configure_sudoers
        configure_user
        exec gosu opencode "$0" "$@"
        exit 0
    fi
    echo "Running as opencode user - proceed with normal startup"
}
