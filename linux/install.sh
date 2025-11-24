#!/bin/bash

# This script requires sudo to create a symbolic link in /etc/keyd/
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo: sudo ./install.sh"
    exit 1
fi

# 1. Get the absolute path of the config file inside the repo
# $(dirname "$0") gets the directory where this script lives
REPO_CONFIG="$(cd "$(dirname "$0")" && pwd)/default.conf"

# 2. Define where the OS expects the config
TARGET_PATH="/etc/keyd/default.conf"

# 3. Backup existing config if it exists (Safety first)
if [ -f "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
    echo "Backing up existing config to ${TARGET_PATH}.bak"
    mv "$TARGET_PATH" "${TARGET_PATH}.bak"
fi

# 4. Create the symbolic link
echo "Linking $REPO_CONFIG -> $TARGET_PATH"
ln -s "$REPO_CONFIG" "$TARGET_PATH"

echo "Done! Configuration is now linked to Git. You may need to restart keyd (e.g., sudo systemctl restart keyd) for changes to take effect."
