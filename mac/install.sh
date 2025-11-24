#!/bin/bash

# Check if Karabiner-Elements is installed
if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
    echo "Error: Karabiner-Elements is not installed in /Applications."
    echo "Please install it from: https://karabiner-elements.pqrs.org/"
    exit 1
fi

# Get the absolute path of the config file inside the repo
REPO_CONFIG="$(cd "$(dirname "$0")" && pwd)/karabiner.json"
TARGET_DIR="$HOME/.config/karabiner"
TARGET_PATH="$TARGET_DIR/karabiner.json"

# Ensure target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating directory $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Check if config already exists
if [ -L "$TARGET_PATH" ]; then
    # It's a symlink - check if it points to our repo
    CURRENT_TARGET="$(readlink -f "$TARGET_PATH" 2>/dev/null || readlink "$TARGET_PATH")"
    REPO_CONFIG_RESOLVED="$(cd "$(dirname "$REPO_CONFIG")" && pwd)/$(basename "$REPO_CONFIG")"
    if [ "$CURRENT_TARGET" = "$REPO_CONFIG_RESOLVED" ]; then
        echo "✓ SuperKeys is already installed and up to date"
        echo "  Symlink: $TARGET_PATH -> $REPO_CONFIG"
        exit 0
    else
        echo "Error: A symlink already exists but points to a different location:"
        echo "  Current: $TARGET_PATH -> $CURRENT_TARGET"
        echo "  Expected: $REPO_CONFIG"
        echo ""
        echo "To reinstall, first remove the existing symlink:"
        echo "  rm $TARGET_PATH"
        exit 1
    fi
elif [ -f "$TARGET_PATH" ]; then
    # It's a regular file
    echo "Error: An existing config file was found at $TARGET_PATH"
    echo ""
    echo "To avoid data loss, this script will not overwrite it."
    echo "Please manually backup or remove the existing file:"
    echo "  mv $TARGET_PATH ${TARGET_PATH}.bak"
    echo "  rm $TARGET_PATH"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Create the symbolic link
echo "Linking $REPO_CONFIG -> $TARGET_PATH"
ln -s "$REPO_CONFIG" "$TARGET_PATH"

# Verify symlink was created
if [ ! -L "$TARGET_PATH" ]; then
    echo "Error: Failed to create symlink"
    exit 1
fi

echo "✓ Symlink created successfully"
echo ""
echo "Done! Your SuperKeys configuration is now active."
echo "Karabiner-Elements should automatically detect the change."