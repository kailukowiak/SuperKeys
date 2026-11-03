#!/bin/bash

# SuperKeys macOS Installer
# Merges SuperKeys profile into existing Karabiner-Elements config

set -e

# Check if Karabiner-Elements is installed
if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
    echo "Karabiner-Elements is not installed in /Applications."
    if command -v brew &> /dev/null; then
        read -r -p "Install it now with Homebrew? [Y/n] " response
        if [ -z "$response" ] || [[ "$response" =~ ^[Yy] ]]; then
            brew install --cask karabiner-elements
        else
            echo "Install it manually and re-run this script:"
            echo "  brew install --cask karabiner-elements"
            echo "  or download from: https://karabiner-elements.pqrs.org/"
            exit 1
        fi
    else
        echo ""
        echo "Install it using one of these methods:"
        echo "  brew install --cask karabiner-elements"
        echo "  or download from: https://karabiner-elements.pqrs.org/"
        exit 1
    fi
fi

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_CONFIG="$SCRIPT_DIR/karabiner.json"
# Personal additions live outside the clone so a dotfiles repo can own them
# (symlinked or copied) and a re-clone or pull never touches them
LOCAL_CONFIG="${SUPERKEYS_LOCAL:-${XDG_CONFIG_HOME:-$HOME/.config}/superkeys/local.json}"
TARGET_DIR="$HOME/.config/karabiner"
TARGET_PATH="$TARGET_DIR/karabiner.json"

# Ensure target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating directory $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Back up the existing config before touching it (README promises this,
# and it protects against the invalid-JSON replacement path below)
if [ -f "$TARGET_PATH" ]; then
    cp "$TARGET_PATH" "$TARGET_PATH.bak"
    echo "Backed up existing config to $TARGET_PATH.bak"
fi

# Use Python to merge configs (available on all modern Macs)
export REPO_CONFIG LOCAL_CONFIG TARGET_PATH
python3 << 'PYTHON_SCRIPT'
import json
import sys
import os
from pathlib import Path

repo_config_path = os.environ['REPO_CONFIG']
local_config_path = os.environ['LOCAL_CONFIG']
target_path = os.environ['TARGET_PATH']

# Read the SuperKeys config from repo
try:
    with open(repo_config_path, 'r') as f:
        repo_config = json.load(f)
except Exception as e:
    print(f"Error reading repo config: {e}")
    sys.exit(1)

# Extract SuperKeys profile from repo config
superkeys_profile = None
for profile in repo_config.get('profiles', []):
    if profile.get('name') == 'SuperKeys':
        superkeys_profile = profile
        break

if not superkeys_profile:
    print("Error: Could not find SuperKeys profile in repo config")
    sys.exit(1)

# Layer the user's mac/local.json on top of the repo profile. Done before the
# target is read so a broken local.json aborts without writing anything.
LOCAL_KEYS = {'rules', 'disable', 'parameters', 'profile'}
if os.path.exists(local_config_path):
    try:
        with open(local_config_path) as f:
            local = json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: {local_config_path} is invalid JSON: {e}")
        sys.exit(1)
    if not isinstance(local, dict):
        print(f"Error: {local_config_path} must be a JSON object")
        sys.exit(1)
    unknown = set(local) - LOCAL_KEYS
    if unknown:
        print(f"Error: unknown keys in local.json: {', '.join(sorted(unknown))}")
        print(f"Allowed keys: {', '.join(sorted(LOCAL_KEYS))}")
        sys.exit(1)
    for key, kind, name in (('rules', list, 'array'), ('disable', list, 'array'),
                            ('parameters', dict, 'object'), ('profile', dict, 'object')):
        if not isinstance(local.get(key, kind()), kind):
            print(f"Error: local.json '{key}' must be a JSON {name}")
            sys.exit(1)

    cm = superkeys_profile.setdefault('complex_modifications', {})
    repo_rules = cm.get('rules', [])

    # "disable": drop repo rules by their description
    disabled = set(local.get('disable', []))
    known = {r.get('description') for r in repo_rules}
    for name in sorted(disabled - known):
        print(f"Warning: local.json disables unknown rule {name!r}")
    repo_rules = [r for r in repo_rules if r.get('description') not in disabled]

    # "rules": go first - Karabiner uses the first manipulator that matches,
    # so a local rule overrides a repo binding on the same key
    local_rules = local.get('rules', [])
    cm['rules'] = local_rules + repo_rules

    # "parameters": e.g. basic.to_if_alone_timeout_milliseconds
    cm.setdefault('parameters', {}).update(local.get('parameters', {}))

    # "profile": other profile-level keys (simple_modifications, devices, ...)
    for key, value in local.get('profile', {}).items():
        if key in ('name', 'selected', 'complex_modifications'):
            print(f"Error: local.json 'profile' may not set {key!r}")
            sys.exit(1)
        superkeys_profile[key] = value

    print(f"✓ Applied local.json: {len(local_rules)} rule(s) added, "
          f"{len(disabled & known)} disabled")

# Read existing user config or create new one
if os.path.exists(target_path):
    try:
        with open(target_path, 'r') as f:
            user_config = json.load(f)
        print(f"Found existing config at {target_path}")
    except json.JSONDecodeError:
        print("Warning: Existing config is invalid JSON, creating new config")
        user_config = {"profiles": []}
else:
    print("No existing config found, creating new one")
    user_config = {"profiles": []}

# Ensure profiles array exists
if 'profiles' not in user_config:
    user_config['profiles'] = []

# Ensure global settings exist
if 'global' not in user_config:
    user_config['global'] = {"show_in_menu_bar": True}

# Find existing SuperKeys profile and check if it was selected
superkeys_index = None
was_superkeys_selected = False
for i, profile in enumerate(user_config['profiles']):
    if profile.get('name') == 'SuperKeys':
        superkeys_index = i
        was_superkeys_selected = profile.get('selected', False)
        break

# Check if any profile is currently selected
any_selected = any(p.get('selected', False) for p in user_config['profiles'])

# Remove 'selected' from the repo profile - we'll set it based on user's config
if 'selected' in superkeys_profile:
    del superkeys_profile['selected']

if superkeys_index is not None:
    # Update existing profile, preserve selection state
    user_config['profiles'][superkeys_index] = superkeys_profile
    if was_superkeys_selected:
        user_config['profiles'][superkeys_index]['selected'] = True
    print("✓ Updated existing SuperKeys profile")
else:
    # Add new profile
    user_config['profiles'].append(superkeys_profile)
    print("✓ Added SuperKeys profile")

    # If no profile was selected, select the new SuperKeys profile
    if not any_selected:
        user_config['profiles'][-1]['selected'] = True
        print("✓ Set SuperKeys as active profile (no previous selection)")

# Write updated config
try:
    with open(target_path, 'w') as f:
        json.dump(user_config, f, indent=4)
    print(f"✓ Config saved to {target_path}")
except Exception as e:
    print(f"Error writing config: {e}")
    sys.exit(1)

# Print profile summary
print("\nProfiles in your config:")
for profile in user_config['profiles']:
    selected = " (active)" if profile.get('selected') else ""
    print(f"  - {profile.get('name', 'Unnamed')}{selected}")

PYTHON_SCRIPT

echo ""
echo "Done! Karabiner-Elements should automatically detect the change."
echo ""
echo "To switch profiles, click the Karabiner icon in the menu bar."
echo "To select SuperKeys as your active profile, use Karabiner-Elements preferences."
