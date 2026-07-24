# SuperKeys bootstrap - install or update with one command (Windows):
#
#   irm https://raw.githubusercontent.com/kailukowiak/SuperKeys/master/bootstrap.ps1 | iex
#
# Safe to re-run: clones to ~\.superkeys on first run, updates afterwards -
# so the same one-liner is also how you update, no need to remember where
# the checkout lives. Override the location with $env:SUPERKEYS_DIR.
#
# Note: uses 'return' instead of 'exit' throughout - under `irm | iex` this
# script runs in the caller's session, and 'exit' would close their console.

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:SUPERKEYS_REPO) { $env:SUPERKEYS_REPO } else { "https://github.com/kailukowiak/SuperKeys.git" }
$Dir = if ($env:SUPERKEYS_DIR) { $env:SUPERKEYS_DIR } else { Join-Path $env:USERPROFILE ".superkeys" }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Error: git is required." -ForegroundColor Red
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Install it with: winget install -e --id Git.Git" -ForegroundColor Yellow
    } else {
        Write-Host "Install it from: https://git-scm.com/download/win" -ForegroundColor Yellow
    }
    return
}

if (Test-Path (Join-Path $Dir ".git")) {
    Write-Host "SuperKeys found at $Dir - updating..."
    & (Join-Path $Dir "windows\update.ps1")
} elseif (Test-Path $Dir) {
    Write-Host "Error: $Dir exists but is not a SuperKeys checkout." -ForegroundColor Red
    Write-Host "Move it aside, or set `$env:SUPERKEYS_DIR to a different location."
    return
} else {
    Write-Host "Installing SuperKeys to $Dir..."
    git clone $RepoUrl $Dir
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: git clone failed" -ForegroundColor Red
        return
    }
    & (Join-Path $Dir "windows\install.ps1")
}
