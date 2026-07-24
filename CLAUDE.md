# CLAUDE.md - AI Assistant Guide for SuperKeys

## Project Overview

SuperKeys is a cross-platform keyboard remapping utility that transforms Caps Lock into a "Hyper" modifier key with vim-style navigation. The project provides identical keyboard shortcuts across Linux, macOS, and Windows.

**Core Concept:** Tap Caps Lock for Escape, hold it to activate the Hyper layer with navigation and editing shortcuts.

## Repository Structure

```
SuperKeys/
├── bootstrap.sh         # curl|bash one-liner: clones to ~/.superkeys, installs or updates
├── bootstrap.ps1        # irm|iex equivalent for Windows (uses return, never exit)
├── install              # Cross-platform installer (bash, auto-detects OS)
├── update               # Cross-platform updater: git pull + re-apply + reload
├── README.md            # User documentation with keyboard layout diagrams
├── LICENSE              # MIT License
├── scripts/
│   └── check_parity.py  # Verifies all 3 configs define the same hyper keys
├── .github/workflows/
│   └── ci.yml           # JSON validation, parity check, shellcheck, PSScriptAnalyzer
├── linux/
│   ├── default.conf     # keyd configuration file
│   ├── install.sh       # Linux installer (requires sudo)
│   └── uninstall.sh     # Removes symlink, restores backup, restarts keyd
├── mac/
│   ├── karabiner.json   # Karabiner-Elements rules
│   ├── install.sh       # macOS installer (merges SuperKeys profile)
│   └── uninstall.sh     # Removes only the SuperKeys profile
└── windows/
    ├── keymap.ahk       # AutoHotkey v2 script
    ├── install.ps1      # Windows PowerShell installer
    └── update.ps1       # git pull + restart the running keymap
```

## Platform-Specific Technologies

| Platform | Tool | Config Location | Syntax |
|----------|------|-----------------|--------|
| Linux | [keyd](https://github.com/rvaiya/keyd) | `/etc/keyd/default.conf` | INI-like sections |
| macOS | [Karabiner-Elements](https://karabiner-elements.pqrs.org/) | `~/.config/karabiner/karabiner.json` | JSON with manipulators |
| Windows | [AutoHotkey v2](https://www.autohotkey.com/) | `%USERPROFILE%\Documents\AutoHotkey\keymap.ahk` | AHK v2 syntax |

## Key Configuration Files

### Linux: `linux/default.conf`
- Uses keyd's simple `key = action` syntax
- Sections: `[ids]` (device filter), `[main]` (base layer), `[hyper]` (hyper layer)
- Modifier syntax: `C-` (Ctrl), `M-` (Alt), `S-` (Shift)
- Layer syntax: `overload(layer, tap_action)` for dual-function keys

### macOS: `mac/karabiner.json`
- JSON format with `rules` array containing `manipulators`
- Hyper key = `right_shift + right_command + right_control + right_option`
- Uses `from.modifiers.mandatory` and `to.modifiers` for key combos
- `to_if_alone` enables tap-vs-hold behavior

### Windows: `windows/keymap.ahk`
- AutoHotkey v2 syntax (requires `#Requires AutoHotkey v2.0`)
- Uses `#HotIf GetKeyState("CapsLock", "P")` for context-sensitive hotkeys (instant response)
- Tap detection: `A_PriorKey = "CapsLock"` at release means no other key was pressed while held → send Escape. No time limit, matching keyd's `overload()`
- Navigation keys use `*key:: Send "{Blind}..."` so held modifiers fall through (Shift selects, Ctrl jumps words), matching keyd's `fallthrough = true`; keys with distinct shift behavior (e.g. `+p::` mute) are defined explicitly

**Why `#HotIf` instead of `CapsLock & key`:**
The custom combination syntax (`CapsLock & key::`) makes CapsLock a "prefix key" - AHK waits to see if another key follows, causing input lag. The `#HotIf` approach checks physical key state instantly, matching keyd/Karabiner behavior.

## Development Guidelines

### Adding a New Shortcut

To add a new hyper shortcut across all platforms:

1. **Linux** (`linux/default.conf`):
   ```ini
   [hyper]
   newkey = target_key
   # or with modifiers:
   newkey = C-target_key
   ```

2. **macOS** (`mac/karabiner.json`):
   Add a new manipulator object to the appropriate rule:
   ```json
   {
     "type": "basic",
     "from": {
       "key_code": "newkey",
       "modifiers": {
         "mandatory": ["right_command", "right_control", "right_shift", "right_option"]
       }
     },
     "to": [{ "key_code": "target_key" }]
   }
   ```

3. **Windows** (`windows/keymap.ahk`):
   Add inside the `#HotIf GetKeyState("CapsLock", "P")` block:
   ```autohotkey
   newkey:: Send "{target_key}"  ; or "^{key}" for Ctrl+key
   ; If Shift should fall through (selection variants), use wildcard + Blind:
   *newkey:: Send "{Blind}{target_key}"
   ; If the shift variant does something different, define it explicitly:
   +newkey:: Send "+{other_key}"
   ```

4. Run `python3 scripts/check_parity.py` - it fails if any platform is
   missing the new key (CI enforces this on every PR).

### Modifier Key Mapping

| Modifier | Linux (keyd) | macOS (Karabiner) | Windows (AHK) |
|----------|--------------|-------------------|---------------|
| Control | `C-` | `left_control` | `^` |
| Alt/Option | `M-` | `left_option` | `!` |
| Shift | `S-` | `left_shift` | `+` |
| Super/Cmd | (not used) | `left_command` | `#` |

### Testing Changes

- **Linux**: Changes apply after `sudo systemctl restart keyd` (validate first with `sudo keyd check`)
- **macOS**: Re-run `./mac/install.sh` (or `./update`) to re-merge the profile; Karabiner then auto-detects the change
- **Windows**: Reload script by right-clicking tray icon → "Reload Script"
- **All platforms**: `./update` (or `windows\update.ps1`) pulls and re-applies in one step

## Installation Architecture

All installers follow the same pattern:
1. Check if required software is installed (offering to install it via the platform's package manager)
2. Back up any existing config before touching it
3. Link the repo config into place:
   - Linux/Windows: symlink from system config location → repo config file
   - Windows without Developer Mode/admin: a loader file that `#Include`s the repo config
   - macOS: merge the SuperKeys profile into the user's `karabiner.json` (Karabiner rewrites its config, so a symlink is not possible)
4. Validate (Linux `keyd check`) and restart/notify the remapping service

Because macOS is a merge, a plain `git pull` is not enough there - the `update`
script (and `windows/update.ps1`) does pull + re-apply + reload on every
platform, and is the documented way to sync machines.

The `bootstrap.sh`/`bootstrap.ps1` one-liners wrap all of this: they clone to
`~/.superkeys` (override: `SUPERKEYS_DIR`) on first run and dispatch to
`update` on later runs, so the same command installs and updates. They are
fetched from the `master` branch raw URL, so changes to them only reach users
after merging. `SUPERKEYS_REPO` overrides the clone URL (used for testing).

### Windows Installer Options

The Windows installer (`windows/install.ps1`) supports command-line switches:
```powershell
.\install.ps1              # Interactive install with autostart prompt
.\install.ps1 -NoAutostart # Skip autostart setup
.\install.ps1 -Uninstall   # Remove SuperKeys completely
```

The installer:
- Auto-detects AutoHotkey v2 installation location
- Creates startup shortcut in user's Startup folder (optional)
- Offers to launch SuperKeys immediately
- Backs up existing configs instead of failing

## Common Tasks

### Updating the Keyboard Layout Diagram
The ASCII diagram in `README.md` (under "Keyboard Layout") should be updated when adding visible shortcuts.

### Platform Parity
When modifying shortcuts, ensure all three platforms behave consistently:
- Same key triggers same action
- Same modifier behavior (Shift for selection, etc.)
- Document any unavoidable platform differences in README.md

### Design Principle: App-Independent Bindings Only
Every hyper binding must send literal keys (arrows, Home/End, PageUp/Down,
Enter, Backspace/Delete) or resolve at the OS level (window switching, media
keys, input switching). Do NOT add app-interpreted commands (find, undo,
close-tab, select-all) - they behave differently per program (e.g. `Ctrl+F`
is find in Chrome but cursor-forward in a shell), which defeats the
muscle-memory goal. Those were deliberately removed; users fall back to each
program's native shortcut.

The one sanctioned exception is the clipboard (`Caps+C/V/X`): it works in
nearly every app including terminals, so its value outweighs its few
misfires (on Linux it emits `Ctrl+Shift+C/V/X` for terminal compatibility,
which is DevTools in Chrome; macOS/Windows use native `Cmd`/`Ctrl+C/V/X`).
Do not add further exceptions without the user asking.

## Code Style Conventions

- **Comments**: Each config section should have a header comment explaining its purpose
- **Ordering**: Group related shortcuts together (navigation, deletion, media, etc.)
- **Naming**: Use descriptive section/rule names that match across platforms

## Git Workflow

- Changes to config files take effect immediately after the appropriate service restart
- Commit messages should indicate which platform(s) are affected
- Test on actual hardware when possible (keyboard input is hardware-dependent)

## Troubleshooting Tips

- **Linux**: Check `sudo systemctl status keyd` and `keyd monitor` for debugging
- **macOS**: Use Karabiner-EventViewer.app to see key events
- **Windows**: AHK v2 includes a built-in key history viewer (right-click tray → "Open")

### Windows-Specific Issues

**Tap-for-Escape not working reliably:**
- Tap detection relies on `A_PriorKey`, which needs AHK's key history enabled (it is by default; don't set `#KeyHistory 0`)
- Ensure no other AHK scripts are intercepting CapsLock

**Keys not responding while CapsLock held:**
- The script uses `#HotIf GetKeyState("CapsLock", "P")` which checks physical key state
- If issues persist, check Windows key repeat settings and other keyboard software

## External Dependencies

| Platform | Required Software | Installation |
|----------|------------------|--------------|
| Linux | keyd | `git clone && make && sudo make install` |
| macOS | Karabiner-Elements | Download from website or `brew install --cask karabiner-elements` |
| Windows | AutoHotkey v2 | Download from autohotkey.com |
