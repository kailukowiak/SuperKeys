#!/bin/bash
# SuperKeys macOS uninstaller
# Removes the SuperKeys profile from karabiner.json, leaving other profiles
# untouched.

set -e

TARGET_PATH="$HOME/.config/karabiner/karabiner.json"

if [ ! -f "$TARGET_PATH" ]; then
    echo "No Karabiner config found at $TARGET_PATH - nothing to remove."
    exit 0
fi

cp "$TARGET_PATH" "$TARGET_PATH.bak"
echo "Backed up config to $TARGET_PATH.bak"

export TARGET_PATH
python3 << 'PYTHON_SCRIPT'
import json
import os
import sys

target_path = os.environ['TARGET_PATH']

with open(target_path) as f:
    config = json.load(f)

profiles = config.get('profiles', [])
remaining = [p for p in profiles if p.get('name') != 'SuperKeys']

if len(remaining) == len(profiles):
    print("No SuperKeys profile found - nothing to remove.")
    sys.exit(0)

# If SuperKeys was the selected profile, fall back to the first remaining one
if remaining and not any(p.get('selected') for p in remaining):
    remaining[0]['selected'] = True

config['profiles'] = remaining

with open(target_path, 'w') as f:
    json.dump(config, f, indent=4)
    f.write('\n')

print("✓ Removed SuperKeys profile")
for p in remaining:
    marker = " (active)" if p.get('selected') else ""
    print(f"  - {p.get('name', 'Unnamed')}{marker}")
PYTHON_SCRIPT

echo ""
echo "Done. Karabiner-Elements picks up the change automatically."
