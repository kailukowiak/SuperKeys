# SuperKeys updater (Windows)
# Pulls the latest configs and reloads the running keymap so changes apply
# immediately - a plain `git pull` leaves the old script running.

$RepoRoot = Split-Path $PSScriptRoot -Parent

Write-Host "Pulling latest changes..."
git -C $RepoRoot pull --ff-only
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: git pull failed" -ForegroundColor Red
    exit 1
}

# Restart the running SuperKeys instance, if any (other AHK scripts untouched)
$running = Get-CimInstance Win32_Process -Filter "Name LIKE 'AutoHotkey%'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*keymap.ahk*" }

if ($running) {
    $TargetFile = "$env:USERPROFILE\Documents\AutoHotkey\keymap.ahk"
    $AhkExe = ($running | Select-Object -First 1).ExecutablePath

    $running | ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }
    Start-Process -FilePath $AhkExe -ArgumentList "`"$TargetFile`""
    Write-Host "✓ SuperKeys reloaded - new config is active" -ForegroundColor Green
} else {
    Write-Host "SuperKeys is not currently running; start it via the installer or startup shortcut." -ForegroundColor Yellow
}
