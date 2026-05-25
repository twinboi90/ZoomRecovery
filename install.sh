#!/bin/bash

set -e

BINARY="zoomrecovery"
INSTALL_DIR="/usr/local/bin"

echo "Installing $BINARY..."

sudo cp "./$BINARY" "$INSTALL_DIR/$BINARY"
sudo chmod +x "$INSTALL_DIR/$BINARY"

# Remove macOS quarantine attribute if present
xattr -d com.apple.quarantine "$INSTALL_DIR/$BINARY" 2>/dev/null || true

echo "Done! Run 'zoomrecovery' from anywhere to get started."
