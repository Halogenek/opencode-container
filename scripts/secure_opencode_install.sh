#!/bin/bash
set -euo pipefail

# Load configuration
CONFIG_FILE="${OPENCODE_CONFIG_FILE:-/app/opencode.config}"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Source the configuration
. "$CONFIG_FILE"

OPENCODE_BIN="${OPENCODE_INSTALL_PATH:-/usr/local/bin/opencode}"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

detect_target() {
    local os
    local arch

    os="$(uname -s)"
    arch="$(uname -m)"

    if [ "$os" != "Linux" ]; then
        echo "ERROR: Unsupported operating system: $os" >&2
        exit 1
    fi

    if command -v ldd >/dev/null 2>&1 && ldd --version 2>&1 | grep -qi musl; then
        echo "ERROR: musl-based systems are not supported by this installer configuration." >&2
        exit 1
    fi

    case "$arch" in
        x86_64 | amd64)
            if grep -qwi avx2 /proc/cpuinfo 2>/dev/null; then
                echo "linux-x64"
            else
                echo "linux-x64-baseline"
            fi
            ;;
        aarch64 | arm64)
            echo "linux-arm64"
            ;;
        *)
            echo "ERROR: Unsupported architecture: $arch" >&2
            exit 1
            ;;
    esac
}

target="$(detect_target)"

case "$target" in
    linux-x64)
        expected_sha256="${OPENCODE_SHA256_LINUX_X64:-}"
        ;;
    linux-x64-baseline)
        expected_sha256="${OPENCODE_SHA256_LINUX_X64_BASELINE:-}"
        ;;
    linux-arm64)
        expected_sha256="${OPENCODE_SHA256_LINUX_ARM64:-}"
        ;;
    *)
        expected_sha256=""
        ;;
esac

echo "Installing OpenCode CLI v${OPENCODE_VERSION} (${target})..."

if [ -n "$expected_sha256" ]; then
    echo "Downloading and verifying package..."

    registry="${NPM_REGISTRY%/}"
    package="${OPENCODE_NPM_SCOPE}/cli-${target}"
    package_name="cli-${target}-${OPENCODE_VERSION}.tgz"
    download_url="${registry}/${package}/-/${package_name}"
    package_path="${TMP_DIR}/${package_name}"

    curl -fsSL --retry 3 -o "$package_path" "$download_url"

    echo "Verifying integrity..."
    calculated_sha256=$(sha256sum "$package_path" | cut -d' ' -f1)

    if [ "$calculated_sha256" != "$expected_sha256" ]; then
        echo "ERROR: SHA256 mismatch!" >&2
        echo "Expected: $expected_sha256" >&2
        echo "Got:      $calculated_sha256" >&2
        exit 1
    fi

    tar -xzf "$package_path" -C "$TMP_DIR" package/bin/opencode
    install -m 0755 "${TMP_DIR}/package/bin/opencode" "$OPENCODE_BIN"
else
    echo "WARNING: No SHA256 configured for ${target}; falling back to npm." >&2
    bash -c "$OPENCODE_INSTALL_CMD"
fi

# Verify installation
echo "Verifying installation..."
if ! installed_version=$(opencode --version 2>&1); then
    echo "ERROR: OpenCode failed to run:" >&2
    echo "$installed_version" >&2
    exit 1
fi

if [[ "$installed_version" == *"${OPENCODE_VERSION}"* ]]; then
    echo "OpenCode CLI v${OPENCODE_VERSION} installed successfully"
else
    echo "ERROR: OpenCode installation verification failed" >&2
    echo "Expected version: ${OPENCODE_VERSION}" >&2
    echo "Got: ${installed_version}" >&2
    exit 1
fi
