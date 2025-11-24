# SuperKeys

Cross-platform keyboard remapping using Caps Lock as a Hyper key. Edit once, sync everywhere.

## What This Does

Transforms Caps Lock into a powerful "Hyper" modifier key with vim-style navigation and editing shortcuts that work consistently across Linux, Mac, and Windows.

**Core Features:**
- **Caps Lock**: Tap for Escape, hold for Hyper key
- **Vim Navigation**: `Caps+H/J/K/L` for arrow keys
- **Text Selection**: Add Shift for selecting while navigating
- **Word/Line Navigation**: Quick movement with `A/E/U/O/I`
- **Smart Deletion**: Multiple delete modes with `N/M/,/.`
- **Universal Clipboard**: `Caps+C/V/X` for copy/paste/cut (works in terminals!)
- **Window Management**: Quick window/tab switching
- **App Shortcuts**: Number keys for launching apps

Your configs stay in this git repo. Install scripts create symlinks so changes sync across machines.

## Installation

Clone the repository:

```bash
git clone https://github.com/kailukowiak/SuperKeys.git
cd SuperKeys
```

Run the installer:

**Linux/Mac:**
```bash
./install
```

**Windows:**
```powershell
cd windows
.\install.ps1
```

The installer will:
- Check if required software is installed
- Backup existing configs
- Create symlinks to this repo
- Auto-restart services (Linux only)

## Uninstalling

Remove the symlink and restore your original config:

**Linux:**
```bash
sudo rm /etc/keyd/default.conf
sudo mv /etc/keyd/default.conf.bak /etc/keyd/default.conf  # if backup exists
sudo systemctl restart keyd
```

**Mac:**
```bash
rm ~/.config/karabiner/karabiner.json
mv ~/.config/karabiner/karabiner.json.bak ~/.config/karabiner/karabiner.json  # if backup exists
```

**Windows:**
```powershell
Remove-Item $env:USERPROFILE\Documents\AutoHotkey\keymap.ahk
Move-Item $env:USERPROFILE\Documents\AutoHotkey\keymap.ahk.bak keymap.ahk  # if backup exists
```

## Keyboard Layout

### Navigation
| Key | Action | With Shift |
|-----|--------|------------|
| `Caps+H` | ← Left | Select left |
| `Caps+J` | ↓ Down | Select down |
| `Caps+K` | ↑ Up | Select up |
| `Caps+L` | → Right | Select right |
| `Caps+A` | Word left | |
| `Caps+E` | Word right | |
| `Caps+U` | Line start | |
| `Caps+O` | Line end | |
| `Caps+I` | Line end (alt) | |
| `Caps+D` | Page down | |
| `Caps+F` | Page up | |

### Editing
| Key | Action |
|-----|--------|
| `Caps+M` | Delete char backward |
| `Caps+N` | Delete word backward |
| `Caps+,` | Delete char forward |
| `Caps+.` | Delete word forward |

### Clipboard
| Key | Action |
|-----|--------|
| `Caps+C` | Copy (works in terminals!) |
| `Caps+V` | Paste (works in terminals!) |
| `Caps+X` | Cut (works in terminals!) |

### Window Control
| Key | Action |
|-----|--------|
| `Caps+W` | Close window/tab |
| `Caps+Q` | Quit application |
| `Caps+Tab` | Switch windows |
| `Caps+Shift+Tab` | Switch windows (reverse) |

### Other
| Key | Action |
|-----|--------|
| `Caps+Esc` | Toggle Caps Lock |
| `Caps+Space` | Language/input switcher |
| `Caps+1-0` | App shortcuts (configurable) |

## Customizing

Edit the config files for your platform:
- **Linux**: `linux/default.conf` (keyd syntax)
- **Mac**: `mac/karabiner.json` (Karabiner-Elements JSON)
- **Windows**: `windows/keymap.ahk` (AutoHotkey v1 syntax)

Changes take effect immediately via the symlink. Commit and push to sync across machines.

## Requirements

**Linux:**
- [keyd](https://github.com/rvaiya/keyd) - `git clone https://github.com/rvaiya/keyd && cd keyd && make && sudo make install`

**Mac:**
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/)

**Windows:**
- [AutoHotkey v1.1](https://www.autohotkey.com/)
- Developer Mode enabled OR run PowerShell as Administrator

## Platform-Specific Notes

### Linux (keyd)
- Clipboard operations use `Ctrl+Shift+C/V/X` for terminal compatibility
- App shortcuts emit `Ctrl+1-0` - bind these in your window manager to launch apps
- Window switching uses `Alt+Tab`
- Quit application uses `Alt+Q`

### Mac (Karabiner)
- Clipboard operations use native `Cmd+C/V/X` (works everywhere including terminals!)
- App shortcuts emit `Ctrl+1-0` - works with tools like Raycast/Alfred
- Window switching uses native `Cmd+Tab`
- Quit application uses `Cmd+Q`

### Windows (AutoHotkey)
- Clipboard operations use native `Ctrl+C/V/X` (standard Windows shortcuts)
- App shortcuts emit `Ctrl+1-0` - bind these in your preferred app launcher
- Window switching uses `Alt+Tab`
- Quit application uses `Alt+F4`
- After installation, double-click the keymap.ahk file to activate
- Set up auto-start by adding a shortcut to the startup folder (instructions shown during install)

## Philosophy

This config prioritizes:
1. **Cross-platform consistency** - Same muscle memory everywhere
2. **Terminal-friendly** - Clipboard works without conflicts
3. **Vim-inspired** - Familiar to vim users, easy for others
4. **Non-intrusive** - Caps Lock is otherwise unused
5. **Git-based** - Version controlled, easily synced

## License

MIT - See [LICENSE](LICENSE) for details
