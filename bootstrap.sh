#!/bin/bash
# SuperKeys bootstrap - install or update with one command (Linux/Mac):
#
#   curl -fsSL https://raw.githubusercontent.com/kailukowiak/SuperKeys/master/bootstrap.sh | bash
#
# Safe to re-run: clones to ~/.superkeys on first run, updates afterwards -
# so the same one-liner is also how you update, no need to remember where
# the checkout lives. Override the location with SUPERKEYS_DIR.

set -e

REPO_URL="${SUPERKEYS_REPO:-https://github.com/kailukowiak/SuperKeys.git}"
DIR="${SUPERKEYS_DIR:-$HOME/.superkeys}"

if ! command -v git &> /dev/null; then
    echo "Error: git is required. Install it with your package manager and re-run."
    exit 1
fi

# When piped from curl, stdin is the script itself - reattach the terminal so
# the installer's prompts (and sudo) work. Skipped when no terminal exists.
if [ ! -t 0 ] && (exec < /dev/tty) 2> /dev/null; then
    exec < /dev/tty
fi

if [ -d "$DIR/.git" ]; then
    echo "SuperKeys found at $DIR - updating..."
    "$DIR/update"
elif [ -e "$DIR" ]; then
    echo "Error: $DIR exists but is not a SuperKeys checkout."
    echo "Move it aside, or set SUPERKEYS_DIR to a different location."
    exit 1
else
    echo "Installing SuperKeys to $DIR..."
    git clone "$REPO_URL" "$DIR"
    "$DIR/install"
fi
