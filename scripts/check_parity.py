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

# keyd composite-layer suffix -> which modifier it represents
KEYD_LAYER_MODS = {"shift": "shift", "alt": "alt"}

# keyd key name -> AutoHotkey hotkey name
KEYD_TO_AHK = {
    "esc": "esc", "space": "space", "tab": "tab", "enter": "enter",
    ",": ",", ".": ".", "/": "/", "[": "[", "]": "]", ";": "`;",
}

# keyd key name -> Karabiner key_code
KEYD_TO_KARABINER = {
    "esc": "escape", "space": "spacebar", "tab": "tab",
    "enter": "return_or_enter", ",": "comma", ".": "period", "/": "slash",
    "[": "open_bracket", "]": "close_bracket", ";": "semicolon",
}


def parse_keyd(path):
    """Return {(key, shift, alt)} bound in [hyper] and its composite layers.

    keyd has no modifier prefix on the left-hand side of a binding; the
    modifier variants live in composite layers instead ([hyper+shift],
    [hyper+alt]), so the section header is what carries shift/alt here.
    """
    keys = set()
    in_hyper = False
    shift = alt = False
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        m = re.match(r"\[([\w+]+)\]$", line)
        if m:
            layers = m.group(1).split("+")
            in_hyper = layers[0] == "hyper"
            mods = set(layers[1:])
            unknown = mods - set(KEYD_LAYER_MODS)
            if in_hyper and unknown:
                sys.exit(f"unrecognised keyd layer modifier(s): {', '.join(sorted(unknown))}")
            shift = "shift" in mods
            alt = "alt" in mods
            continue
        if not in_hyper or "=" not in line:
            continue
        key = line.split("=", 1)[0].strip().lower()
        keys.add((key, shift, alt))
    return keys


def lint_keyd(path):
    """Flag keyd syntax that loads with warnings instead of failing loudly.

    keyd only warns about these at load time, so a bad line silently drops the
    binding. CI runners have no keyd, hence this stands in for `keyd check`.
    """
    errors = []
    for n, raw in enumerate(path.read_text().splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith("[") or "=" not in line:
            continue
        lhs, rhs = (part.strip() for part in line.split("=", 1))
        where = f"linux/default.conf:{n}"
        if re.match(r"^[CMSAG]-", lhs):
            errors.append(
                f"{where}: '{lhs}' - keyd takes no modifier prefix on the left-hand "
                f"side; put this in a composite layer such as [hyper+shift]"
            )
        if lhs == "fallthrough":
            errors.append(
                f"{where}: 'fallthrough' is not a keyd v2 directive; unbound keys "
                f"already fall through to the layer below"
            )
        # Key names are lowercase - 'M-F4' parses as an invalid action
        target = re.sub(r"^(?:[CMSAG]-)+", "", rhs)
        if re.search(r"[A-Z]", target) and "(" not in target:
            errors.append(f"{where}: '{rhs}' - keyd key names are lowercase")
    return errors


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

    errors = lint_keyd(ROOT / "linux" / "default.conf")

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
