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
    echo "── Tip: Caps+C/V/X in Chromium-based browsers ───────────────────────"
    echo "Your browser hardwires Ctrl+Shift+C to DevTools, so Caps+C opens"
    echo "DevTools instead of copying. Optional fix with keyd's per-app"
    echo "mapper - run once:"
    echo ""
    echo "  sudo usermod -aG keyd \$USER    # log out and back in after this"
    echo "  mkdir -p ~/.config/keyd"
    echo "  cat >> ~/.config/keyd/app.conf <<'CONF'"
    local s
    for s in "${sections[@]}"; do
        echo "[$s]"
        echo "hyper.c = C-c"
        echo "hyper.v = C-v"
        echo "hyper.x = C-x"
    done
    echo "CONF"
    echo "  keyd-application-mapper -d     # add this to your autostart"
    echo ""
    echo "The 'hyper.' prefix is required: keyd never re-reads its own"
    echo "output, so a bare 'C-S-c = C-c' would only match a physical"
    echo "Ctrl+Shift+C press and never Caps+C. The group change only takes"
    echo "effect at login - until you log back in the mapper cannot reach"
    echo "keyd, and silently applies nothing."
    echo ""
    echo "DevTools inspect stays available via Ctrl+Shift+I or F12."
    echo "Works on: X11; wlroots Wayland; GNOME Wayland (needs keyd's"
    echo "bundled shell extension - see the keyd README); KDE."

    # COSMIC ships a zcosmic_toplevel_info_v1 version that keyd's mapper
    # cannot drive, so the recipe above is a silent no-op there. Detect the
    # compositor by process - this runs under sudo, where the desktop env
    # vars are not available.
    if pgrep -x cosmic-comp > /dev/null 2>&1; then
        echo ""
        echo "!! On COSMIC (this machine) the above currently does nothing."
        echo "   keyd's mapper binds zcosmic_toplevel_info_v1 at the version"
        echo "   COSMIC advertises (3), where the 'toplevel' event it relies"
        echo "   on is no longer sent - so it reports 'cosmic detected' and"
        echo "   then never sees a window. Binding version 1 restores the"
        echo "   full event stream. It can also crash parsing window titles."
        echo "   Both are upstream keyd bugs (present in v2.5.0); until they"
        echo "   are fixed, use native Ctrl+C/V/X in your browser."
        echo "   If bindings stop applying, check ~/.config/keyd/app.log."
    fi
    echo "Verify window class names with: keyd-application-mapper -v"
    echo "─────────────────────────────────────────────────────────────────────"
}
