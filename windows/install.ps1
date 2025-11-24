# IMPORTANT: This script requires either:
# 1. Windows Developer Mode enabled, OR
# 2. Running PowerShell as Administrator

# Check if AutoHotkey is installed
$AhkInstalled = Get-Command "AutoHotkey" -ErrorAction SilentlyContinue
# Common default install paths for v1 and v2
$AhkPathV1 = "${env:ProgramFiles}\AutoHotkey\AutoHotkey.exe"
$AhkPathV2 = "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey.exe"

if (-not $AhkInstalled -and -not (Test-Path $AhkPathV1) -and -not (Test-Path $AhkPathV2)) {
    Write-Host "Error: AutoHotkey is not detected." -ForegroundColor Red
    Write-Host "Please install AutoHotkey (v1.1 or v2): https://www.autohotkey.com/"
    Write-Host "If installed, ensure it is in your PATH or installed to the default location."
    exit 1
}

# Get the absolute path of the config file inside the repo
$RepoConfig = Join-Path $PSScriptRoot "keymap.ahk"
$TargetDir = "$env:USERPROFILE\Documents\AutoHotkey"
$TargetFile = "$TargetDir\keymap.ahk"

# Ensure directory exists
if (-not (Test-Path $TargetDir)) {
    Write-Host "Creating directory $TargetDir"
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# Check if config already exists
if (Test-Path $TargetFile) {
    $item = Get-Item $TargetFile
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        # It's a symlink - check if it points to our repo
        $currentTarget = $item.Target
        if ($currentTarget -eq $RepoConfig) {
            Write-Host "✓ SuperKeys is already installed and up to date" -ForegroundColor Green
            Write-Host "  Symlink: $TargetFile -> $RepoConfig"
            exit 0
        } else {
            Write-Host "Error: A symlink already exists but points to a different location:" -ForegroundColor Red
            Write-Host "  Current: $TargetFile -> $currentTarget"
            Write-Host "  Expected: $RepoConfig"
            Write-Host ""
            Write-Host "To reinstall, first remove the existing symlink:"
            Write-Host "  Remove-Item $TargetFile"
            exit 1
        }
    } else {
        # It's a regular file
        Write-Host "Error: An existing config file was found at $TargetFile" -ForegroundColor Red
        Write-Host ""
        Write-Host "To avoid data loss, this script will not overwrite it."
        Write-Host "Please manually backup or remove the existing file:"
        Write-Host "  Move-Item $TargetFile ${TargetFile}.bak"
        Write-Host "  Remove-Item $TargetFile"
        Write-Host ""
        Write-Host "Then run this script again."
        exit 1
    }
}

# Create the Symbolic Link
Write-Host "Linking $RepoConfig -> $TargetFile"
try {
    New-Item -ItemType SymbolicLink -Path $TargetFile -Target $RepoConfig -ErrorAction Stop | Out-Null
} catch {
    Write-Host "Error: Failed to create symlink" -ForegroundColor Red
    Write-Host "This script requires either:" -ForegroundColor Yellow
    Write-Host "  1. Windows Developer Mode enabled, OR"
    Write-Host "  2. Running PowerShell as Administrator"
    Write-Host ""
    Write-Host "To enable Developer Mode: Settings > Update & Security > For developers > Developer Mode"
    exit 1
}

# Verify symlink was created
if (-not (Test-Path $TargetFile)) {
    Write-Host "Error: Failed to create symlink" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Symlink created successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Done! Your SuperKeys configuration is now active." -ForegroundColor Green
Write-Host "Run the script to load your AutoHotkey configuration."