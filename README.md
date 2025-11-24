# Super Keys

Master Plan: Cross-Platform Keyboard Configuration Repository

## Installation

Clone the repository:

```bash
git clone [https://github.com/yourname/keyboard-configs.git](https://github.com/yourname/keyboard-configs.git)
cd keyboard-configs
```

Run the installer for your platform:

*   **Linux**: `cd linux && sudo chmod +x install.sh && sudo ./install.sh`
*   **Mac**: `cd mac && chmod +x install.sh && ./install.sh`
*   **Windows**: Right-click `windows\install.ps1` and select "Run with PowerShell".

---

1. Objective

Create a single Git repository to manage keyboard remapping configurations for Linux, macOS, and Windows. The goal is to allow a user to `git clone` the repo and run a simple script to "install" the config via symbolic links (symlinks).

2. Repository Structure

The file structure must isolate operating systems to prevent conflicts and keep installation logic clean.

```
keyboard-configs/
├── README.md               # Documentation and usage guide
├── .gitattributes          # Line-ending normalization (Critical)
│
├── linux/
│   ├── install.sh          # Bash script for Linux
│   └── default.conf        # Keyd config file
│
├── mac/
│   ├── install.sh          # Bash script for macOS
│   └── karabiner.json      # Example config file (e.g., Karabiner Elements)
│
└── windows/
    ├── install.ps1         # PowerShell script for Windows
    └── keymap.ahk          # Example config file (e.g., AutoHotKey)
```

3. Git Configuration (`.gitattributes`)

To prevent line-ending corruption (CRLF vs LF) when moving between Windows and Unix systems, create a `.gitattributes` file in the root.

Content for `.gitattributes`:

```
# Detect text files automatically
* text=auto

# Force LF (Unix style) for shell scripts
*.sh text eol=lf

# Force CRLF (Windows style) for PowerShell and Batch
*.ps1 text eol=crlf
*.bat text eol=crlf

# AutoHotKey generally prefers CRLF but handles LF; force CRLF for consistency
*.ahk text eol=crlf
```

4. Installation Logic (Symlinking)

The core mechanism is Symbolic Linking. We do not copy files; we link the system's expected config path back to this git repository.

A. Linux & macOS (`install.sh`)

This script should detect the current directory and link the specific config file to the user's home or config directory.

Template `linux/install.sh` / `mac/install.sh`:

```bash
#!/bin/bash

# 1. Get the absolute path of the config file inside the repo
# $(dirname "$0") gets the directory where this script lives
REPO_CONFIG="$(cd "$(dirname "$0")" && pwd)/YOUR_CONFIG_FILENAME"

# 2. Define where the OS expects the config
# Linux Example: "/etc/keyd/default.conf"
# Mac Example: "$HOME/.config/karabiner/karabiner.json"
TARGET_PATH="$HOME/.config/path/to/target"

# 3. Backup existing config if it exists (Safety first)
if [ -f "$TARGET_PATH" ] || [ -L "$TARGET_PATH" ]; then
    echo "Backing up existing config to ${TARGET_PATH}.bak"
    mv "$TARGET_PATH" "${TARGET_PATH}.bak"
fi

# 4. Create the symbolic link
echo "Linking $REPO_CONFIG -> $TARGET_PATH"
ln -s "$REPO_CONFIG" "$TARGET_PATH"

echo "Done! Configuration is now linked to Git."
```

B. Windows (`install.ps1`)

Windows requires PowerShell (often as Administrator) to create symbolic links.

Template `windows/install.ps1`:

```powershell
# 1. Get the absolute path of the config file inside the repo
$RepoConfig = Join-Path $PSScriptRoot "keymap.ahk"

# 2. Define where the OS expects the config
$TargetDir = "$env:USERPROFILE\Documents\AutoHotkey"
$TargetFile = "$TargetDir\keymap.ahk"

# Ensure directory exists
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# 3. Backup existing config
if (Test-Path $TargetFile) {
    Write-Host "Backing up existing config..."
    Move-Item -Path $TargetFile -Destination "$TargetFile.bak" -Force
}

# 4. Create the Symbolic Link
# Note: Requires Developer Mode ON or Admin privileges
Write-Host "Linking $RepoConfig -> $TargetFile"
New-Item -ItemType SymbolicLink -Path $TargetFile -Target $RepoConfig

Write-Host "Done! Configuration is now linked to Git."
```
