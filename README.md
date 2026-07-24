# SuperKeys

Cross-platform keyboard remapping using Caps Lock as a Hyper key. Edit once, sync everywhere.

## Special Thanks

This was initially inspired by https://github.com/Vonng/Capslock.

## What This Does

Transforms Caps Lock into a powerful "Hyper" modifier key with vim-style navigation and editing shortcuts that work consistently across Linux, Mac, and Windows.

**Core Features:**
- **Caps Lock**: Tap for Escape, hold for Hyper key
- **Vim Navigation**: `Caps+H/J/K/L` for arrow keys
- **Text Selection**: Add Shift for selecting while navigating
- **Word/Line Navigation**: Quick movement with `A/E/U/O`
- **Editing**: Select all, undo/redo, find with `I/Z/Shift+Z//`
- **Smart Deletion**: Multiple delete modes with `N/M/,/.`
- **Universal Clipboard**: `Caps+C/V/X` for copy/paste/cut (works in terminals!)
- **Window Management**: Quick window/tab switching, tab cycling with `[/]`
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
- Check if required software is installed (and offer to install it via your package manager)
- Backup existing configs
- Link this repo's configs into place (macOS merges a profile instead - see note below)
- Validate and restart services (Linux)

## Updating

Don't just `git pull` - macOS needs the profile re-merged and Linux/Windows need
the service or script reloaded. The update scripts do all of it in one step:

**Linux/Mac:**
```bash
./update
```

**Windows:**
```powershell
.\windows\update.ps1
```

On Linux and Windows the configs are symlinked, so a plain `git pull` does
change the files - but the running service keeps the old config until reloaded.
On macOS the SuperKeys profile is merged (copied) into `karabiner.json`, so a
pull alone changes nothing until you re-run `./update` or the installer.

## Uninstalling

**Linux:**
```bash
cd linux && sudo ./uninstall.sh
```

**Mac:**
```bash
cd mac && ./uninstall.sh
```
This removes only the SuperKeys profile from `karabiner.json`; your other profiles are untouched.

**Windows:**
```powershell
cd windows
.\install.ps1 -Uninstall
```

## Keyboard Layout

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  CAPS LOCK LAYER  (Hold Caps Lock + Key)                                         │
├───────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬──────────────┤
│  Esc  │ App │ App │ App │ App │ App │ App │ App │ App │ App │ App │              │
│ TogCap│  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  0  │              │
├───────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬─────┬─────┤
│          │ Quit│Close│Word→│ App │ App │     │Line←│ All │Line→│     │ Tab←│ Tab→│
│          │  Q  │  W  │  E  │  R  │  T  │  Y  │  U  │  I  │  O  │  P  │  [  │  ]  │
├──────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┤
│  [HYPER]   │Word←│     │ PgDn│ PgUp│ App │  ←  │  ↓  │  ↑  │  →  │     │         │
│ CAPS LOCK  │  A  │  S  │  D  │  F  │  G  │  H  │  J  │  K  │  L  │  ;  │         │
├────────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──────┤
│               │ Undo│ Cut │ Copy│Paste│     │ Del │ Del │ Del │ Del │ Find│      │
│               │  Z  │  X  │  C  │  V  │  B  │  N  │  M  │  ,  │  .  │  /  │      │
├───────────────┼─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴──────┤
│               │                      Space  (Input Switch)                       │
└──────────────────────────────────────────────────────────────────────────────────┘

Tap Caps Lock = Escape    │    Hold Caps Lock = Hyper Modifier
```

### Navigation
| Key | Action | With Shift |
|-----|--------|------------|
| `Caps+H` | ← Left | Select left |
| `Caps+J` | ↓ Down | Select down |
| `Caps+K` | ↑ Up | Select up |
| `Caps+L` | → Right | Select right |
| `Caps+A` | Word left | Select word left |
| `Caps+E` | Word right | Select word right |
| `Caps+U` | Line start | Select to line start |
| `Caps+O` | Line end | Select to line end |
| `Caps+D` | Page down | |
| `Caps+F` | Page up | |

### Editing
| Key | Action |
|-----|--------|
| `Caps+I` | Select all |
| `Caps+Z` | Undo |
| `Caps+Shift+Z` | Redo |
| `Caps+/` | Find |
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
| `Caps+[` | Previous tab |
| `Caps+]` | Next tab |

### Other
| Key | Action |
|-----|--------|
| `Caps+Esc` | Toggle Caps Lock |
| `Caps+Space` | Language/input switcher |
| `Caps+Alt+Space` | Emoji/alternate input switcher |
| `Caps+Enter` | Terminal shortcut (Ctrl/Cmd+Enter) |
| `Caps+1-0` | App shortcuts (configurable) |
| `Caps+G/R/T` | App shortcuts (configurable) |

## Customizing

Edit the config files for your platform:
- **Linux**: `linux/default.conf` (keyd syntax)
- **Mac**: `mac/karabiner.json` (Karabiner-Elements JSON)
- **Windows**: `windows/keymap.ahk` (AutoHotkey v2 syntax)

Changes apply after a service reload: `sudo systemctl restart keyd` on Linux,
automatic on macOS after re-running `./update`, right-click tray icon → Reload
on Windows. Commit and push, then run the update script on your other machines.

Run `python3 scripts/check_parity.py` after editing to verify all three
platforms still define the same keys (CI runs this too).

## Requirements

**Linux:**
- [keyd](https://github.com/rvaiya/keyd) - the installer offers to install it from your distro's packages; or build from source: `git clone https://github.com/rvaiya/keyd && cd keyd && make && sudo make install`

**Mac:**
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) - the installer offers to install it via Homebrew

**Windows:**
- [AutoHotkey v2](https://www.autohotkey.com/) - the installer offers to install it via winget
- Developer Mode or Administrator gets you a symlink; without either, the installer falls back to a loader file automatically

## Platform-Specific Notes

### Linux (keyd)
- Clipboard operations use `Ctrl+Shift+C/V/X` for terminal compatibility
- App shortcuts emit `Alt+1-0` and `Alt+G/R/T` - bind these in your window manager to launch apps
- Window switching uses `Alt+Tab`
- Quit application uses `Alt+F4`

### Mac (Karabiner)
- Clipboard operations use native `Cmd+C/V/X` (works everywhere including terminals!)
- App shortcuts emit `Ctrl+1-0` and `Ctrl+G/R/T` - works with tools like Raycast/Alfred
- Window switching uses native `Cmd+Tab`
- Quit application uses `Cmd+Q`

### Windows (AutoHotkey)
- Clipboard operations use native `Ctrl+C/V/X` (standard Windows shortcuts)
- App shortcuts emit `Ctrl+1-0` and `Ctrl+G/R/T` - bind these in your preferred app launcher
- Window switching uses `Alt+Tab`
- Quit application uses `Alt+F4`
- Installer offers to set up autostart and launch immediately
- To uninstall: `.\install.ps1 -Uninstall`

### Tap behavior
Tap-for-Escape fires when Caps Lock is released without any other key having
been pressed - there is no time limit, matching keyd's `overload()` on all
platforms (Karabiner uses a generous 5s window).

## Philosophy

This config prioritizes:
1. **Cross-platform consistency** - Same muscle memory everywhere
2. **Terminal-friendly** - Clipboard works without conflicts
3. **Vim-inspired** - Familiar to vim users, easy for others
4. **Non-intrusive** - Caps Lock is otherwise unused
5. **Git-based** - Version controlled, easily synced

## License

MIT - See [LICENSE](LICENSE) for details
