# 1. Get the absolute path of the config file inside the repo
$RepoConfig = Join-Path $PSScriptRoot "keymap.ahk"

# 2. Define where the OS expects the config
# Using Documents/AutoHotkey as a standard location, though users might run it from anywhere.
$TargetDir = "$env:USERPROFILE\Documents\AutoHotkey"
$TargetFile = "$TargetDir\keymap.ahk"

# Ensure directory exists
if (-not (Test-Path $TargetDir)) {
    Write-Host "Creating directory $TargetDir"
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
