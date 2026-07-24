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
- **Smart Deletion**: Multiple delete modes with `N/M/,/.`
- **Clipboard**: `Caps+C/V/X` for copy/paste/cut (works in terminals!)
- **Home-Row Enter**: `Caps+;` for Enter without leaving home position
- **Media Controls**: `Caps+P/[/]` for play-pause and volume
- **Window Switching**: `Caps+Tab` / `Caps+Q`
- **App Shortcuts**: Number keys for launching apps

**Design principle - only keys that behave the same everywhere.** Every
binding either sends literal keys (arrows, Home/End, PageUp/Down, Enter,
Backspace/Delete) or resolves at the OS level (window switching, media,
input switching). Shortcuts that apps interpret themselves - find, undo,
close-tab - are deliberately *not* bound, because they mean different
things in different programs (`Ctrl+F` is find in Chrome but
cursor-forward in a shell). For those, use each program's native shortcut;
your muscle memory for them already works.

The one deliberate exception is the clipboard (`Caps+C/V/X`): it works in
nearly every app *including terminals*, which native `Ctrl+C` can't do.
The rare misfires (e.g. on Linux `Ctrl+Shift+C` opens DevTools in Chrome)
are a price worth paying - just use the native shortcut there.

Your configs stay in this git repo. Install scripts create symlinks so changes sync across machines.

## Installation

One command - it clones SuperKeys to `~/.superkeys` and runs the right
installer for your OS. **Re-run the same command any time to update**; it
finds the existing checkout for you, so you never need to remember where it
lives.

**Linux/Mac:**
```bash
curl -fsSL https://raw.githubusercontent.com/kailukowiak/SuperKeys/master/bootstrap.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/kailukowiak/SuperKeys/master/bootstrap.ps1 | iex
```

Set `SUPERKEYS_DIR` to install somewhere other than `~/.superkeys` (use the
same value on later runs, including from an existing manual clone).

<details>
<summary>Manual install (clone wherever you like)</summary>

```bash
git clone https://github.com/kailukowiak/SuperKeys.git
cd SuperKeys
./install          # Linux/Mac
```

```powershell
cd windows
.\install.ps1      # Windows
```

</details>

The installer will:
- Check if required software is installed (and offer to install it via your package manager)
- Backup existing configs
- Link this repo's configs into place (macOS merges a profile instead - see note below)
- Validate and restart services (Linux)

## Updating

**Easiest: re-run the install one-liner above.** It notices the existing
checkout and updates it - pull, re-apply, reload - wherever you are.

From inside the checkout, the update scripts do the same thing:

**Linux/Mac:**
```bash
./update
```

**Windows:**
```powershell
.\windows\update.ps1
```

Don't just `git pull` - macOS needs the profile re-merged and Linux/Windows
need the service or script reloaded; the scripts handle all of it.

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
│          │ Quit│     │Word→│ App │ App │     │Line←│     │Line→│ Play│ Vol-│ Vol+│
│          │  Q  │  W  │  E  │  R  │  T  │  Y  │  U  │  I  │  O  │  P  │  [  │  ]  │
├──────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┤
│  [HYPER]   │Word←│     │ PgDn│ PgUp│ App │  ←  │  ↓  │  ↑  │  →  │Enter│         │
│ CAPS LOCK  │  A  │  S  │  D  │  F  │  G  │  H  │  J  │  K  │  L  │  ;  │         │
├────────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──────┤
│               │     │ Cut │ Copy│Paste│     │ Del │ Del │ Del │ Del │     │      │
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

### Deletion
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
| `Caps+Q` | Quit application |
| `Caps+Tab` | Switch windows |
| `Caps+Shift+Tab` | Switch windows (reverse) |

### Media
| Key | Action |
|-----|--------|
| `Caps+P` | Play / pause |
| `Caps+Shift+P` | Mute |
| `Caps+[` | Volume down |
| `Caps+]` | Volume up |

### Other
| Key | Action |
|-----|--------|
| `Caps+;` | Enter (home-row) |
| `Caps+Esc` | Toggle Caps Lock |
| `Caps+Space` | Language/input switcher |
| `Caps+Alt+Space` | Emoji/alternate input switcher |
| `Caps+1-0` | App shortcuts (configurable) |
| `Caps+G/R/T` | App shortcuts (configurable) |

### Deliberately not bound
Find, undo/redo, select-all, close-tab, and similar are app-interpreted
commands - they'd behave differently in a terminal than in Chrome or Word.
Use each program's native shortcut for those; apart from the clipboard
exception above, the hyper layer only carries keys that mean the same
thing everywhere.

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
- Clipboard emits `Ctrl+Shift+C/V/X` for terminal compatibility (caveat: Chromium-based browsers - Chrome, Chromium, Brave, Edge, Opera - hardwire `Ctrl+Shift+C` to DevTools; Vivaldi alone can rebind it natively. Either use native `Ctrl+C` there, or set up [keyd's per-app mapper](https://github.com/rvaiya/keyd#application-specific-remapping) - the installer and updater print a copy-pasteable recipe covering the browsers they detect. DevTools inspect stays available via `Ctrl+Shift+I`/`F12`)
- The per-app recipe binds `hyper.c = C-c`, **not** `C-S-c = C-c`. keyd never re-reads its own output, so a binding without the layer prefix only matches a *physical* `Ctrl+Shift+C` press - never `Caps+C` - and does nothing. The `usermod -aG keyd` step in the recipe also only takes effect at your next login; before that the mapper starts, connects to nothing and silently applies no bindings
- **COSMIC users:** the per-app mapper does not work at all as of keyd v2.5.0. It binds `zcosmic_toplevel_info_v1` at the version COSMIC advertises (3), where the `toplevel` event it depends on is no longer sent, so it detects no windows (binding version 1 restores the event stream). It can additionally crash while parsing window titles. Both are upstream keyd bugs - until they are fixed, use native `Ctrl+C/V/X` in Chromium-based browsers on COSMIC
- App shortcuts emit `Alt+1-0` and `Alt+G/R/T` - bind these in your window manager to launch apps
- Window switching uses `Alt+Tab`
- Quit application uses `Alt+F4`

### Mac (Karabiner)
- Clipboard emits native `Cmd+C/V/X` (works everywhere including terminals)
- App shortcuts emit `Ctrl+1-0` and `Ctrl+G/R/T` - works with tools like Raycast/Alfred
- Window switching uses native `Cmd+Tab`
- Quit application uses `Cmd+Q`

### Windows (AutoHotkey)
- Clipboard emits `Ctrl+C/V/X` (in most terminals `Ctrl+C` still copies when text is selected)
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
2. **App-independent** - Only literal keys and OS-level actions, so nothing changes meaning between programs
3. **Vim-inspired** - Familiar to vim users, easy for others
4. **Non-intrusive** - Caps Lock is otherwise unused
5. **Git-based** - Version controlled, easily synced

## License

MIT - See [LICENSE](LICENSE) for details
