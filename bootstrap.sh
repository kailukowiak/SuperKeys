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

# When piped from curl, this script IS bash's stdin, and bash reads it one
# command at a time - so fd 0 must never be replaced here (`exec < /dev/tty`
# makes bash look for the rest of the script on the terminal, i.e. hang
# silently). Instead give the terminal to the installer only, so its prompts
# and sudo still work. Falls back to /dev/null when there is no terminal.
if [ -t 0 ]; then
    TTY_IN=""                       # already interactive; children inherit it
elif { : < /dev/tty; } 2> /dev/null; then
    TTY_IN=/dev/tty
else
    TTY_IN=/dev/null
fi

# Run a command with the terminal (not the curl pipe) on its stdin
run_interactive() {
    if [ -n "$TTY_IN" ]; then
        "$@" < "$TTY_IN"
    else
        "$@"
    fi
}

if [ -d "$DIR/.git" ]; then
    echo "SuperKeys found at $DIR - updating..."
    run_interactive "$DIR/update"
elif [ -e "$DIR" ]; then
    echo "Error: $DIR exists but is not a SuperKeys checkout."
    echo "Move it aside, or set SUPERKEYS_DIR to a different location."
    exit 1
else
    echo "Installing SuperKeys to $DIR..."
    run_interactive git clone "$REPO_URL" "$DIR"
    run_interactive "$DIR/install"
fi
