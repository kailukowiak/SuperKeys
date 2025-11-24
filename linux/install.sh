#!/bin/bash

# This script requires sudo to create a symbolic link in /etc/keyd/
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo: sudo ./install.sh"
    exit 1
fi

# Check if keyd is installed
if ! command -v keyd &> /dev/null; then
    echo "Error: 'keyd' is not installed or not in your PATH."
    echo "Please install keyd first: https://github.com/rvaiya/keyd"
    echo "Installation summary:"
    echo "  git clone https://github.com/rvaiya/keyd"
    echo "  cd keyd && make && sudo make install"
    echo "  sudo systemctl enable keyd && sudo systemctl start keyd"
    exit 1
fi

# Get the absolute path of the config file inside the repo
REPO_CONFIG="$(cd "$(dirname "$0")" && pwd)/default.conf"
TARGET_DIR="/etc/keyd"
TARGET_PATH="$TARGET_DIR/default.conf"

# Ensure /etc/keyd directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating directory $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Check if config already exists
SYMLINK_ALREADY_EXISTS=false
if [ -L "$TARGET_PATH" ]; then
    # It's a symlink - check if it points to our repo
    CURRENT_TARGET="$(readlink -f "$TARGET_PATH")"
    if [ "$CURRENT_TARGET" = "$REPO_CONFIG" ]; then
        echo "✓ SuperKeys is already installed and up to date"
        echo "  Symlink: $TARGET_PATH -> $REPO_CONFIG"
        SYMLINK_ALREADY_EXISTS=true
    else
        echo "Error: A symlink already exists but points to a different location:"
        echo "  Current: $TARGET_PATH -> $CURRENT_TARGET"
        echo "  Expected: $REPO_CONFIG"
        echo ""
        echo "To reinstall, first remove the existing symlink:"
        echo "  sudo rm $TARGET_PATH"
        exit 1
    fi
elif [ -f "$TARGET_PATH" ]; then
    # It's a regular file
    echo "Error: An existing config file was found at $TARGET_PATH"
    echo ""
    echo "To avoid data loss, this script will not overwrite it."
    echo "Please manually backup or remove the existing file:"
    echo "  sudo mv $TARGET_PATH ${TARGET_PATH}.bak"
    echo "  sudo rm $TARGET_PATH"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Create the symbolic link if it doesn't already exist
if [ "$SYMLINK_ALREADY_EXISTS" = false ]; then
    echo "Linking $REPO_CONFIG -> $TARGET_PATH"
    ln -s "$REPO_CONFIG" "$TARGET_PATH"

    # Verify symlink was created
    if [ ! -L "$TARGET_PATH" ]; then
        echo "Error: Failed to create symlink"
        exit 1
    fi

    echo "✓ Symlink created successfully"
fi

# Restart keyd to apply changes
echo "Restarting keyd..."
systemctl restart keyd

if systemctl is-active --quiet keyd; then
    echo "✓ keyd restarted successfully"
    echo ""
    echo "Done! Your SuperKeys configuration is now active."
else
    echo "Warning: keyd service may not be running properly"
    echo "Check status with: sudo systemctl status keyd"
fi