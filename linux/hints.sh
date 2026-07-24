#!/bin/bash
# Post-install/update hints for Linux. Sourced by linux/install.sh and the
# repo-level update script; safe to source multiple times.

# Chromium-based browsers hardwire Ctrl+Shift+C to DevTools and (except
# Vivaldi) offer no way to rebind it, so the SuperKeys copy chord misfires
# there. keyd's optional per-app mapper can fix it; that needs per-user
# setup we shouldn't automate blindly, so print a copy-pasteable recipe
# covering exactly the browsers that are installed. Deliberately no right
# border on the command lines - trailing characters would break pasting.
print_chrome_copy_hint() {
    local sections=()
    if command -v google-chrome &> /dev/null || command -v google-chrome-stable &> /dev/null; then
        sections+=("google-chrome*")
    fi
    if command -v chromium &> /dev/null || command -v chromium-browser &> /dev/null; then
        sections+=("chromium*")
    fi
    if command -v brave-browser &> /dev/null || command -v brave &> /dev/null; then
        sections+=("brave-browser*")
    fi
    if command -v microsoft-edge &> /dev/null || command -v microsoft-edge-stable &> /dev/null; then
        sections+=("microsoft-edge*")
    fi
    if command -v vivaldi &> /dev/null || command -v vivaldi-stable &> /dev/null; then
        sections+=("vivaldi*")
    fi
    if command -v opera &> /dev/null; then
        sections+=("opera*")
    fi

    [ ${#sections[@]} -eq 0 ] && return 0

    echo ""
    echo "── Tip: Caps+C copy in Chromium-based browsers ──────────────────────"
    echo "Your browser hardwires Ctrl+Shift+C to DevTools, so Caps+C won't"
    echo "copy there. Optional fix with keyd's per-app mapper - run once:"
    echo ""
    echo "  sudo usermod -aG keyd \$USER    # then log out and back in"
    echo "  mkdir -p ~/.config/keyd"
    echo "  cat >> ~/.config/keyd/app.conf <<'CONF'"
    local s
    for s in "${sections[@]}"; do
        echo "[$s]"
        echo "C-S-c = C-c"
    done
    echo "CONF"
    echo "  keyd-application-mapper -d     # add this to your autostart"
    echo ""
    echo "DevTools inspect stays available via Ctrl+Shift+I or F12."
    echo "Works on: X11; COSMIC and wlroots Wayland (needs a recent keyd -"
    echo "build from git master if unsure); GNOME Wayland (needs keyd's"
    echo "bundled shell extension - see the keyd README); KDE."
    echo "Verify window class names with: keyd-application-mapper -v"
    echo "─────────────────────────────────────────────────────────────────────"
}
