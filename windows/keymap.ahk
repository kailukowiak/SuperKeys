; SuperKeys - Cross-platform Hyper Key Configuration
; Caps Lock as Hyper key with vim-style navigation
; AutoHotkey v2.0
;
; CapsLock: tap for Escape, hold for Hyper key
; This implementation uses #HotIf for instant response (no prefix key delay)

#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

; ============================================
; Configuration
; ============================================
global TapTimeout := 200  ; ms - max time for a "tap" to register as Escape

; ============================================
; State Tracking
; ============================================
global CapsDownTime := 0
global CapsUsedAsModifier := false

; Disable CapsLock LED/toggle state
SetCapsLockState "AlwaysOff"

; ============================================
; CapsLock Press/Release Handling
; ============================================
; On CapsLock down: record time, reset modifier flag
*CapsLock:: {
    global CapsDownTime, CapsUsedAsModifier
    CapsDownTime := A_TickCount
    CapsUsedAsModifier := false
}

; On CapsLock up: send Escape if it was a quick tap with no other keys
*CapsLock up:: {
    global CapsDownTime, CapsUsedAsModifier, TapTimeout
    elapsed := A_TickCount - CapsDownTime
    if (!CapsUsedAsModifier && elapsed < TapTimeout) {
        Send "{Escape}"
    }
}

; Helper: mark that CapsLock was used as a modifier
MarkUsed() {
    global CapsUsedAsModifier := true
}

; ============================================
; Context: CapsLock is physically held down
; ============================================
#HotIf GetKeyState("CapsLock", "P")

; --- Toggle real CapsLock ---
Esc:: {
    MarkUsed()
    SetCapsLockState !GetKeyState("CapsLock", "T")
}

; --- Vim Navigation (HJKL) ---
h:: {
    MarkUsed()
    Send "{Left}"
}
+h:: {  ; Shift+H while CapsLock held = select left
    MarkUsed()
    Send "+{Left}"
}

j:: {
    MarkUsed()
    Send "{Down}"
}
+j:: {
    MarkUsed()
    Send "+{Down}"
}

k:: {
    MarkUsed()
    Send "{Up}"
}
+k:: {
    MarkUsed()
    Send "+{Up}"
}

l:: {
    MarkUsed()
    Send "{Right}"
}
+l:: {
    MarkUsed()
    Send "+{Right}"
}

; --- Word/Line/Page Navigation ---
a:: {
    MarkUsed()
    Send "^{Left}"  ; Word left
}
+a:: {
    MarkUsed()
    Send "^+{Left}"  ; Select word left
}

e:: {
    MarkUsed()
    Send "^{Right}"  ; Word right
}
+e:: {
    MarkUsed()
    Send "^+{Right}"  ; Select word right
}

u:: {
    MarkUsed()
    Send "{Home}"  ; Line start
}
+u:: {
    MarkUsed()
    Send "+{Home}"  ; Select to line start
}

o:: {
    MarkUsed()
    Send "{End}"  ; Line end
}
+o:: {
    MarkUsed()
    Send "+{End}"  ; Select to line end
}

i:: {
    MarkUsed()
    Send "{End}"  ; Line end (alternate)
}
+i:: {
    MarkUsed()
    Send "+{End}"  ; Select to line end
}

d:: {
    MarkUsed()
    Send "{PgDn}"  ; Page down
}

f:: {
    MarkUsed()
    Send "{PgUp}"  ; Page up
}

; --- Deletion ---
n:: {
    MarkUsed()
    Send "^{Backspace}"  ; Delete word backward
}

m:: {
    MarkUsed()
    Send "{Backspace}"  ; Delete char backward
}

,:: {
    MarkUsed()
    Send "{Delete}"  ; Delete char forward
}

.:: {
    MarkUsed()
    Send "^{Delete}"  ; Delete word forward
}

; --- Clipboard ---
c:: {
    MarkUsed()
    Send "^c"  ; Copy
}

v:: {
    MarkUsed()
    Send "^v"  ; Paste
}

x:: {
    MarkUsed()
    Send "^x"  ; Cut
}

; --- Window Control ---
w:: {
    MarkUsed()
    Send "^w"  ; Close tab/window
}

q:: {
    MarkUsed()
    Send "!{F4}"  ; Quit application
}

Tab:: {
    MarkUsed()
    Send "!{Tab}"  ; Switch windows
}
+Tab:: {
    MarkUsed()
    Send "+!{Tab}"  ; Switch windows (reverse)
}

; --- App Shortcuts (Ctrl+Number) ---
1:: {
    MarkUsed()
    Send "^1"
}
2:: {
    MarkUsed()
    Send "^2"
}
3:: {
    MarkUsed()
    Send "^3"
}
4:: {
    MarkUsed()
    Send "^4"
}
5:: {
    MarkUsed()
    Send "^5"
}
6:: {
    MarkUsed()
    Send "^6"
}
7:: {
    MarkUsed()
    Send "^7"
}
8:: {
    MarkUsed()
    Send "^8"
}
9:: {
    MarkUsed()
    Send "^9"
}
0:: {
    MarkUsed()
    Send "^0"
}

; --- Language/Input Switcher ---
Space:: {
    MarkUsed()
    Send "^{Space}"
}

#HotIf  ; End CapsLock context
