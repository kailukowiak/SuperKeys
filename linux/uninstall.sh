#!/bin/bash
# SuperKeys Linux uninstaller
# Removes the config symlink, restores any backup, and restarts keyd.

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo: sudo ./uninstall.sh"
    exit 1
fi

TARGET_PATH="/etc/keyd/default.conf"

if [ -L "$TARGET_PATH" ]; then
    rm "$TARGET_PATH"
    echo "✓ Removed symlink $TARGET_PATH"
elif [ -f "$TARGET_PATH" ]; then
    echo "Note: $TARGET_PATH is a regular file, not a SuperKeys symlink - leaving it alone."
else
    echo "No config found at $TARGET_PATH - nothing to remove."
fi

# Restore the most recent backup, if the path is now free. Handles both the
# legacy plain '.bak' and the timestamped '.bak.<YYYYmmddHHMMSS>' the
# installer writes; the glob sorts oldest-to-newest, so the last hit wins.
if [ ! -e "$TARGET_PATH" ]; then
    RESTORE_FROM=""
    for candidate in "$TARGET_PATH".bak "$TARGET_PATH".bak.*; do
        [ -f "$candidate" ] && RESTORE_FROM="$candidate"
    done

    if [ -n "$RESTORE_FROM" ]; then
        mv "$RESTORE_FROM" "$TARGET_PATH"
        echo "✓ Restored backup config from $RESTORE_FROM"
    fi
fi

if command -v keyd &> /dev/null && systemctl is-active --quiet keyd; then
    systemctl restart keyd
    echo "✓ keyd restarted"
fi

echo "Done. SuperKeys has been uninstalled."
