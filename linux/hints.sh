#!/bin/bash
# Post-install/update hints for Linux. Sourced by linux/install.sh and the
# repo-level update script; safe to source multiple times.

# Chrome binds Ctrl+Shift+C to DevTools and offers no way to rebind it, so
# the SuperKeys copy chord misfires there. keyd's optional per-app mapper
# can fix it; that needs per-user setup we shouldn't automate blindly, so
# just point the user at it when Chrome is installed.
print_chrome_copy_hint() {
    if command -v google-chrome &> /dev/null \
        || command -v google-chrome-stable &> /dev/null \
        || command -v chromium &> /dev/null \
        || command -v chromium-browser &> /dev/null; then
        cat << 'EOF'

┌─ Tip: Caps+C copy in Chrome ────────────────────────────────────────┐
│ Chrome uses Ctrl+Shift+C for DevTools and can't rebind it, so       │
│ Caps+C won't copy there. Optional fix with keyd's per-app mapper:   │
│                                                                     │
│   1. sudo usermod -aG keyd $USER   (then log out/in once)           │
│   2. Create ~/.config/keyd/app.conf containing:                     │
│        [google-chrome]                                              │
│        C-S-c = C-c                                                  │
│        [chromium]                                                   │
│        C-S-c = C-c                                                  │
│   3. Run keyd-application-mapper -d  (add it to your autostart)     │
│                                                                     │
│ DevTools inspect stays available via Ctrl+Shift+I or F12.           │
│ Works on: X11; COSMIC and wlroots Wayland (needs a recent keyd -    │
│ build from git master if unsure); GNOME Wayland (needs keyd's       │
│ bundled shell extension - see the keyd README); KDE.                │
│ Verify window class names with: keyd-application-mapper -v          │
└─────────────────────────────────────────────────────────────────────┘
EOF
    fi
}
