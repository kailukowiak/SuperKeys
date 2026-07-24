#!/bin/bash

# This script requires sudo to create a symbolic link in /etc/keyd/
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo: sudo ./install.sh"
    exit 1
fi

# Check if keyd is installed; offer to install it from the distro's packages
if ! command -v keyd &> /dev/null; then
    echo "'keyd' is not installed or not in your PATH."

    PKG_CMD=()
    if command -v apt-get &> /dev/null; then
        PKG_CMD=(apt-get install -y keyd)
    elif command -v dnf &> /dev/null; then
        PKG_CMD=(dnf install -y keyd)
    elif command -v pacman &> /dev/null; then
        PKG_CMD=(pacman -S --noconfirm keyd)
    elif command -v zypper &> /dev/null; then
        PKG_CMD=(zypper install -y keyd)
    fi

    if [ ${#PKG_CMD[@]} -gt 0 ]; then
        read -r -p "Install keyd now via '${PKG_CMD[*]}'? [Y/n] " response
        if [ -z "$response" ] || [[ "$response" =~ ^[Yy] ]]; then
            if "${PKG_CMD[@]}" && command -v keyd &> /dev/null; then
                systemctl enable keyd
                echo "✓ keyd installed"
            else
                echo "Package install failed (keyd may not be in your distro's repos)."
                echo "Build it from source instead:"
                echo "  git clone https://github.com/rvaiya/keyd"
                echo "  cd keyd && make && sudo make install"
                echo "  sudo systemctl enable keyd && sudo systemctl start keyd"
                exit 1
            fi
        else
            exit 1
        fi
    else
        echo "Please install keyd first: https://github.com/rvaiya/keyd"
        echo "Installation summary:"
        echo "  git clone https://github.com/rvaiya/keyd"
        echo "  cd keyd && make && sudo make install"
        echo "  sudo systemctl enable keyd && sudo systemctl start keyd"
        exit 1
    fi
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

# Check if config already exists. Anything in the way is moved aside to a
# timestamped backup rather than deleted, so re-pointing an old install at a
# new checkout just works (and never silently loses a hand-written config).
SYMLINK_ALREADY_EXISTS=false
if [ -L "$TARGET_PATH" ]; then
    # It's a symlink - check if it points to our repo
    CURRENT_TARGET="$(readlink -f "$TARGET_PATH")"
    if [ "$CURRENT_TARGET" = "$REPO_CONFIG" ]; then
        echo "✓ SuperKeys is already installed and up to date"
        echo "  Symlink: $TARGET_PATH -> $REPO_CONFIG"
        SYMLINK_ALREADY_EXISTS=true
    else
        echo "Replacing existing symlink:"
        echo "  Was: $TARGET_PATH -> $CURRENT_TARGET"
        echo "  Now: $TARGET_PATH -> $REPO_CONFIG"
        rm "$TARGET_PATH"
    fi
elif [ -e "$TARGET_PATH" ]; then
    # A real file (or directory) - back it up before taking the path over
    BACKUP_PATH="${TARGET_PATH}.bak.$(date +%Y%m%d%H%M%S)"
    echo "Existing config found at $TARGET_PATH"
    echo "Backing it up to $BACKUP_PATH"
    mv "$TARGET_PATH" "$BACKUP_PATH"
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

# Validate the config before restarting, so a typo can't take the keyboard
# down ('keyd check' exists in recent keyd versions)
if keyd --help 2>&1 | grep -q '\bcheck\b'; then
    if ! keyd check; then
        echo "Error: keyd rejected the config. Fix the errors above and re-run."
        exit 1
    fi
    echo "✓ Config validated"
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

# shellcheck source=linux/hints.sh
. "$(cd "$(dirname "$0")" && pwd)/hints.sh"
print_chrome_copy_hint