#!/bin/bash

# Check if Karabiner-Elements is installed
if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
    echo "Error: Karabiner-Elements is not installed in /Applications."
    echo "Please install it from: https://karabiner-elements.pqrs.org/"
    exit 1
fi

# 1. Get the absolute path of the config file inside the repo
REPO_CONFIG="$(cd "$(dirname "$0")" && pwd)/karabiner.json"

# 2. Define where the OS expects the config
# Standard location for Karabiner-Elements config
TARGET_DIR="$HOME/.config/karabiner"
TARGET_PATH="$TARGET_DIR/karabiner.json"

# Ensure target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating directory $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# 3. Backup existing config if it exists
if [ -f "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
    echo "Backing up existing config to ${TARGET_PATH}.bak"
    mv "$TARGET_PATH" "${TARGET_PATH}.bak"
fi

# 4. Create the symbolic link
echo "Linking $REPO_CONFIG -> $TARGET_PATH"
ln -s "$REPO_CONFIG" "$TARGET_PATH"

echo "Done! Configuration is now linked to Git."