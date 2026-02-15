#!/bin/bash
set -e

# Load configuration
CONFIG_FILE="/app/opencode.config"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Source the configuration
. "$CONFIG_FILE"

echo "Installing OpenCode CLI v${OPENCODE_VERSION}..."

# Method 1: Download and verify package before installation
if [ -n "$OPENCODE_SHA256" ] && [ "$OPENCODE_SHA256" != "YOUR_VERIFIED_SHA256_HASH_HERE" ]; then
    echo "Downloading and verifying package..."
    
    # Download package
    PACKAGE_NAME="opencode-ai-${OPENCODE_VERSION}.tgz"
    npm pack "opencode-ai@${OPENCODE_VERSION}" --registry="$NPM_REGISTRY"
    
    # Verify SHA256 hash
    echo "Verifying integrity..."
    CALCULATED_SHA256=$(sha256sum "$PACKAGE_NAME" | cut -d' ' -f1)
    
    if [ "$CALCULATED_SHA256" != "$OPENCODE_SHA256" ]; then
        echo "ERROR: SHA256 mismatch!"
        echo "Expected: $OPENCODE_SHA256"
        echo "Got:      $CALCULATED_SHA256"
        rm -f "$PACKAGE_NAME"
        exit 1
    fi
    
    # Install from verified package
    npm install -g "$PACKAGE_NAME"
    rm -f "$PACKAGE_NAME"
else
    # Method 2: Direct installation (less secure but simpler)
    echo "Installing directly from npm registry..."
    bash -c "$OPENCODE_INSTALL_CMD"
fi

# Verify installation
echo "Verifying installation..."
OPENCODE_INSTALLED_VERSION=$(opencode --version 2>/dev/null || echo "not installed")

if [[ "$OPENCODE_INSTALLED_VERSION" == *"${OPENCODE_VERSION}"* ]]; then
    echo "✓ OpenCode CLI v${OPENCODE_VERSION} installed successfully"
else
    echo "ERROR: OpenCode installation verification failed"
    echo "Expected version: ${OPENCODE_VERSION}"
    echo "Got: ${OPENCODE_INSTALLED_VERSION}"
    exit 1
fi