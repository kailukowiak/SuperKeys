# SuperKeys

Cross-platform keyboard remapping configuration using symlinks. Edit once, sync everywhere.

## What This Does

- **Linux (keyd)**: Caps Lock as Hyper key with vim-style navigation, word/line movements, and app shortcuts
- **Mac (Karabiner)**: Placeholder config (Caps→Esc/Ctrl)
- **Windows (AutoHotkey)**: Placeholder config (Caps→Esc/Ctrl)

Your configs stay in this git repo. Install scripts create symlinks so changes sync across your machines.

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
- Check if required software is installed (keyd/Karabiner/AutoHotkey)
- Create necessary directories
- Symlink configs (won't overwrite existing files)
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

## License

MIT - See [LICENSE](LICENSE) for details