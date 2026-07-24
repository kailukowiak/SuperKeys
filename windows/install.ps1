# SuperKeys Windows Installer
# Prefers a symlink (requires Developer Mode or Administrator); falls back to
# a small loader file that needs no special privileges.

param(
    [switch]$Uninstall,
    [switch]$NoAutostart
)

# ============================================
# Helpers
# ============================================
# Stop only AutoHotkey processes running our keymap - never other AHK scripts
function Stop-SuperKeysProcess {
    Get-CimInstance Win32_Process -Filter "Name LIKE 'AutoHotkey%'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like "*keymap.ahk*" } |
        ForEach-Object {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
}

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

if (-not $AhkExe -and -not $Uninstall) {
    Write-Host "AutoHotkey v2 is not installed." -ForegroundColor Yellow
    $winget = Get-Command "winget" -ErrorAction SilentlyContinue
    if ($winget) {
        $response = Read-Host "Install it now via winget? [Y/n]"
        if ($response -eq "" -or $response -match "^[Yy]") {
            winget install -e --id AutoHotkey.AutoHotkey
            $AhkExe = Find-AutoHotkey
        }
    }
    if (-not $AhkExe) {
        Write-Host "Error: AutoHotkey v2 is not installed." -ForegroundColor Red
        Write-Host ""
        Write-Host "Please install AutoHotkey v2 from: https://www.autohotkey.com/" -ForegroundColor Yellow
        Write-Host "Download the installer and select 'v2' during installation."
        exit 1
    }
}

if ($AhkExe) {
    Write-Host "Found AutoHotkey: $AhkExe" -ForegroundColor Gray
}

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

    # Remove symlink (or loader file)
    if (Test-Path $TargetFile) {
        Remove-Item $TargetFile -Force
        Write-Host "✓ Removed config link" -ForegroundColor Green
    }

    # Kill running instance (only ours - other AHK scripts are left alone)
    Stop-SuperKeysProcess

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
$LoaderSignature = "; SuperKeys loader"

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
    } elseif ((Get-Content $TargetFile -First 1 -ErrorAction SilentlyContinue) -eq $LoaderSignature) {
        # It's a loader file from a previous install
        if (Select-String -Path $TargetFile -Pattern ([regex]::Escape($RepoConfig)) -Quiet) {
            Write-Host "✓ Config loader already exists" -ForegroundColor Green
            $NeedSymlink = $false
        } else {
            Write-Host "Removing loader pointing to a different location" -ForegroundColor Yellow
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
        # No Developer Mode / not elevated: fall back to a loader file, which
        # is a regular file and needs no special privileges. It #Includes the
        # repo config, so edits there still apply on reload.
        Write-Host "Symlink not permitted; using a loader file instead (no admin needed)" -ForegroundColor Yellow
        $loader = @(
            $LoaderSignature
            "; Auto-generated - do not edit. The real config lives in the repo:"
            "#Requires AutoHotkey v2.0"
            "#Include `"$RepoConfig`""
        ) -join "`r`n"
        Set-Content -Path $TargetFile -Value $loader -Encoding UTF8
        Write-Host "✓ Loader created: $TargetFile -> $RepoConfig" -ForegroundColor Green
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
    # Kill any existing SuperKeys instance first (other AHK scripts untouched)
    Stop-SuperKeysProcess

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
