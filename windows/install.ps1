# SuperKeys Windows Installer
# IMPORTANT: This script requires either:
# 1. Windows Developer Mode enabled, OR
# 2. Running PowerShell as Administrator

param(
    [switch]$Uninstall,
    [switch]$NoAutostart
)

# ============================================
# Find AutoHotkey Installation
# ============================================
function Find-AutoHotkey {
    # Check common locations
    $locations = @(
        "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe",
        "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey32.exe",
        "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey.exe",
        "${env:ProgramFiles}\AutoHotkey\AutoHotkey.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\AutoHotkey.exe",
        "${env:LOCALAPPDATA}\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "${env:LOCALAPPDATA}\Programs\AutoHotkey\v2\AutoHotkey.exe"
    )

    foreach ($loc in $locations) {
        if (Test-Path $loc) {
            return $loc
        }
    }

    # Try PATH
    $inPath = Get-Command "AutoHotkey64.exe" -ErrorAction SilentlyContinue
    if ($inPath) { return $inPath.Source }

    $inPath = Get-Command "AutoHotkey.exe" -ErrorAction SilentlyContinue
    if ($inPath) { return $inPath.Source }

    return $null
}

$AhkExe = Find-AutoHotkey

if (-not $AhkExe) {
    Write-Host "Error: AutoHotkey v2 is not installed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install AutoHotkey v2 from: https://www.autohotkey.com/" -ForegroundColor Yellow
    Write-Host "Download the installer and select 'v2' during installation."
    exit 1
}

Write-Host "Found AutoHotkey: $AhkExe" -ForegroundColor Gray

# ============================================
# Path Configuration
# ============================================
$RepoConfig = Join-Path $PSScriptRoot "keymap.ahk"
$TargetDir = "$env:USERPROFILE\Documents\AutoHotkey"
$TargetFile = "$TargetDir\keymap.ahk"
$StartupFolder = [Environment]::GetFolderPath('Startup')
$StartupShortcut = Join-Path $StartupFolder "SuperKeys.lnk"

# ============================================
# Uninstall Mode
# ============================================
if ($Uninstall) {
    Write-Host "Uninstalling SuperKeys..." -ForegroundColor Yellow

    # Remove startup shortcut
    if (Test-Path $StartupShortcut) {
        Remove-Item $StartupShortcut -Force
        Write-Host "✓ Removed autostart shortcut" -ForegroundColor Green
    }

    # Remove symlink
    if (Test-Path $TargetFile) {
        Remove-Item $TargetFile -Force
        Write-Host "✓ Removed config symlink" -ForegroundColor Green
    }

    # Kill running instance
    Get-Process | Where-Object { $_.MainWindowTitle -like "*SuperKeys*" -or $_.ProcessName -eq "AutoHotkey64" -or $_.ProcessName -eq "AutoHotkey" } | ForEach-Object {
        $_.CloseMainWindow() | Out-Null
    }

    Write-Host ""
    Write-Host "SuperKeys has been uninstalled." -ForegroundColor Green
    exit 0
}

# ============================================
# Install: Create Directory
# ============================================
if (-not (Test-Path $TargetDir)) {
    Write-Host "Creating directory $TargetDir"
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# ============================================
# Install: Create Symlink
# ============================================
$NeedSymlink = $true

if (Test-Path $TargetFile) {
    $item = Get-Item $TargetFile
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        # It's a symlink
        $currentTarget = $item.Target
        if ($currentTarget -eq $RepoConfig) {
            Write-Host "✓ Config symlink already exists" -ForegroundColor Green
            $NeedSymlink = $false
        } else {
            Write-Host "Removing old symlink pointing to: $currentTarget" -ForegroundColor Yellow
            Remove-Item $TargetFile -Force
        }
    } else {
        # Regular file - back it up
        $backupPath = "${TargetFile}.bak"
        Write-Host "Backing up existing config to: $backupPath" -ForegroundColor Yellow
        Move-Item $TargetFile $backupPath -Force
    }
}

if ($NeedSymlink) {
    Write-Host "Creating symlink: $TargetFile -> $RepoConfig"
    try {
        New-Item -ItemType SymbolicLink -Path $TargetFile -Target $RepoConfig -ErrorAction Stop | Out-Null
        Write-Host "✓ Symlink created successfully" -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to create symlink" -ForegroundColor Red
        Write-Host ""
        Write-Host "This script requires either:" -ForegroundColor Yellow
        Write-Host "  1. Windows Developer Mode enabled"
        Write-Host "     Settings > System > For developers > Developer Mode"
        Write-Host ""
        Write-Host "  2. OR run PowerShell as Administrator"
        exit 1
    }
}

# ============================================
# Install: Setup Autostart
# ============================================
$SetupAutostart = $false

if (-not $NoAutostart) {
    if (Test-Path $StartupShortcut) {
        Write-Host "✓ Autostart shortcut already exists" -ForegroundColor Green
    } else {
        # Ask user
        Write-Host ""
        $response = Read-Host "Would you like SuperKeys to start automatically with Windows? [Y/n]"
        if ($response -eq "" -or $response -match "^[Yy]") {
            $SetupAutostart = $true
        }
    }
}

if ($SetupAutostart) {
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($StartupShortcut)
        $Shortcut.TargetPath = $AhkExe
        $Shortcut.Arguments = "`"$TargetFile`""
        $Shortcut.WorkingDirectory = $TargetDir
        $Shortcut.Description = "SuperKeys - Hyper Key Configuration"
        $Shortcut.Save()
        Write-Host "✓ Autostart shortcut created" -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not create autostart shortcut" -ForegroundColor Yellow
        Write-Host "  You can manually add a shortcut to: $TargetFile"
        Write-Host "  In the Startup folder: $StartupFolder"
    }
}

# ============================================
# Install: Launch SuperKeys
# ============================================
Write-Host ""
$launch = Read-Host "Would you like to start SuperKeys now? [Y/n]"
if ($launch -eq "" -or $launch -match "^[Yy]") {
    # Kill any existing instance first
    Get-Process | Where-Object { $_.ProcessName -match "AutoHotkey" } | ForEach-Object {
        try {
            $_.CloseMainWindow() | Out-Null
            Start-Sleep -Milliseconds 500
        } catch {}
    }

    Start-Process -FilePath $AhkExe -ArgumentList "`"$TargetFile`""
    Write-Host "✓ SuperKeys is now running" -ForegroundColor Green
}

# ============================================
# Done
# ============================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SuperKeys installed successfully!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  - Tap CapsLock for Escape"
Write-Host "  - Hold CapsLock + HJKL for arrow keys"
Write-Host "  - Hold CapsLock + other keys for shortcuts"
Write-Host ""
Write-Host "Management:" -ForegroundColor Yellow
Write-Host "  - Right-click tray icon to reload/exit"
Write-Host "  - Re-run this script to reinstall"
Write-Host "  - Run with -Uninstall to remove"
Write-Host ""
