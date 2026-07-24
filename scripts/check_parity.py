#!/usr/bin/env python3
"""Cross-platform parity check for SuperKeys configs.

Treats the keyd config (linux/default.conf) as the source of truth for which
hyper-layer keys exist, and verifies that every one of them is also bound in
the AutoHotkey script (windows/keymap.ahk) and the Karabiner config
(mac/karabiner.json). Also flags keys bound on Windows/macOS that keyd does
not know about. What each key *does* is platform-specific by design; this
only checks coverage, which is where drift actually happens.

Run from the repo root: python3 scripts/check_parity.py
Exits non-zero if any platform is missing a binding.
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# keyd names that are layer options, not key bindings
KEYD_NON_KEYS = {"fallthrough"}

# keyd key name -> AutoHotkey hotkey name
KEYD_TO_AHK = {
    "esc": "esc", "space": "space", "tab": "tab", "enter": "enter",
    ",": ",", ".": ".", "/": "/", "[": "[", "]": "]",
}

# keyd key name -> Karabiner key_code
KEYD_TO_KARABINER = {
    "esc": "escape", "space": "spacebar", "tab": "tab",
    "enter": "return_or_enter", ",": "comma", ".": "period", "/": "slash",
    "[": "open_bracket", "]": "close_bracket",
}


def parse_keyd(path):
    """Return {(key, shift, alt)} bound in the [hyper] section."""
    keys = set()
    section = None
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"\[(\w+)\]", line)
        if m:
            section = m.group(1)
            continue
        if section != "hyper" or "=" not in line:
            continue
        lhs = line.split("=", 1)[0].strip()
        shift = lhs.startswith("S-")
        alt = lhs.startswith("M-")
        key = re.sub(r"^[SM]-", "", lhs).lower()
        if key in KEYD_NON_KEYS:
            continue
        keys.add((key, shift, alt))
    return keys


def parse_ahk(path):
    """Return {(key, shift, alt, wildcard)} defined inside the CapsLock #HotIf block."""
    keys = set()
    in_block = False
    for line in path.read_text().splitlines():
        stripped = line.strip()
        if stripped.startswith("#HotIf"):
            in_block = "GetKeyState" in stripped
            continue
        if not in_block:
            continue
        m = re.match(r"([*+!#^]*)(\S+?)::", stripped)
        if m:
            prefix, key = m.groups()
            keys.add((key.lower(), "+" in prefix, "!" in prefix, "*" in prefix))
    return keys


def parse_karabiner(path):
    """Return {(key_code, shift, alt)} from the SuperKeys profile's hyper manipulators."""
    config = json.loads(path.read_text())
    profile = next(p for p in config["profiles"] if p["name"] == "SuperKeys")
    keys = set()
    for rule in profile["complex_modifications"]["rules"]:
        for manip in rule["manipulators"]:
            frm = manip["from"]
            key = frm.get("key_code")
            if key == "caps_lock":
                continue
            mandatory = frm.get("modifiers", {}).get("mandatory", [])
            if not any(m.startswith("right_") for m in mandatory):
                continue  # not a hyper binding
            shift = "left_shift" in mandatory
            alt = "left_option" in mandatory
            keys.add((key, shift, alt))
    return keys


def main():
    keyd = parse_keyd(ROOT / "linux" / "default.conf")
    ahk = parse_ahk(ROOT / "windows" / "keymap.ahk")
    karabiner = parse_karabiner(ROOT / "mac" / "karabiner.json")

    errors = []

    for key, shift, alt in sorted(keyd):
        label = ("S-" if shift else "") + ("M-" if alt else "") + key

        ahk_key = KEYD_TO_AHK.get(key, key)
        # A wildcard AHK hotkey (*key with {Blind}) covers the shift variant
        if not any(
            k == ahk_key and a == alt and (s == shift or (shift and w))
            for k, s, a, w in ahk
        ):
            errors.append(f"windows/keymap.ahk is missing hyper+{label}")

        kb_key = KEYD_TO_KARABINER.get(key, key)
        if (kb_key, shift, alt) not in karabiner:
            errors.append(f"mac/karabiner.json is missing hyper+{label}")

    # Reverse direction: keys bound elsewhere that keyd doesn't have (base keys
    # only - wildcard/shift fan-out makes exact variant comparison too noisy)
    keyd_base = {k for k, _, _ in keyd}
    ahk_to_keyd = {v: k for k, v in KEYD_TO_AHK.items()}
    for k, _, _, _ in sorted(ahk):
        if ahk_to_keyd.get(k, k) not in keyd_base:
            errors.append(f"windows/keymap.ahk binds hyper+{k}, absent from linux/default.conf")
    kb_to_keyd = {v: k for k, v in KEYD_TO_KARABINER.items()}
    for k, _, _ in sorted(karabiner):
        if kb_to_keyd.get(k, k) not in keyd_base:
            errors.append(f"mac/karabiner.json binds hyper+{k}, absent from linux/default.conf")

    if errors:
        print("Parity check FAILED:")
        for e in sorted(set(errors)):
            print(f"  - {e}")
        return 1

    print(f"Parity check passed: {len(keyd)} hyper bindings consistent across all platforms.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
