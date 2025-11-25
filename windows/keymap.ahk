; SuperKeys - Cross-platform Hyper Key Configuration
; Caps Lock as Hyper key with vim-style navigation
; AutoHotkey v2.0
;
; CapsLock: tap for Escape, hold for Hyper key

#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetWorkingDir A_ScriptDir

; Disable CapsLock for its normal functionality
SetCapsLockState "AlwaysOff"

; Track whether CapsLock was used as modifier
CapsUsedAsModifier := false

; CapsLock detection: tap for Escape, hold for Hyper
*CapsLock:: {
    global CapsUsedAsModifier
    CapsUsedAsModifier := false
    KeyWait "CapsLock"
}

*CapsLock up:: {
    global CapsUsedAsModifier
    if (!CapsUsedAsModifier) {
        Send "{Escape}"
    }
    CapsUsedAsModifier := false
}

; Helper function to mark CapsLock as used with a key
MarkCapsUsed() {
    global CapsUsedAsModifier
    CapsUsedAsModifier := true
}

; ============================================
; Caps+Esc: Toggle CapsLock
; ============================================
CapsLock & Esc:: {
    MarkCapsUsed()
    SetCapsLockState !GetKeyState("CapsLock", "T")
}

; ============================================
; Vim-style Navigation (HJKL)
; ============================================
CapsLock & h:: {
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send "+{Left}"
    else
        Send "{Left}"
}

CapsLock & j:: {
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send "+{Down}"
    else
        Send "{Down}"
}

CapsLock & k:: {
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send "+{Up}"
    else
        Send "{Up}"
}

CapsLock & l:: {
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send "+{Right}"
    else
        Send "{Right}"
}

; ============================================
; Word/Line/Page Navigation
; ============================================
CapsLock & a:: {
    MarkCapsUsed()
    Send "^{Left}"  ; Word left
}

CapsLock & e:: {
    MarkCapsUsed()
    Send "^{Right}"  ; Word right
}

CapsLock & u:: {
    MarkCapsUsed()
    Send "{Home}"  ; Line start
}

CapsLock & o:: {
    MarkCapsUsed()
    Send "{End}"  ; Line end
}

CapsLock & i:: {
    MarkCapsUsed()
    Send "{End}"  ; Line end (alternate)
}

CapsLock & d:: {
    MarkCapsUsed()
    Send "{PgDn}"  ; Page down
}

CapsLock & f:: {
    MarkCapsUsed()
    Send "{PgUp}"  ; Page up
}

; ============================================
; Deletion
; ============================================
CapsLock & n:: {
    MarkCapsUsed()
    Send "^{Backspace}"  ; Delete word backward
}

CapsLock & m:: {
    MarkCapsUsed()
    Send "{Backspace}"  ; Delete char backward
}

CapsLock & ,:: {
    MarkCapsUsed()
    Send "{Delete}"  ; Delete char forward
}

CapsLock & .:: {
    MarkCapsUsed()
    Send "^{Delete}"  ; Delete word forward
}

; ============================================
; Clipboard (Cut/Copy/Paste)
; ============================================
CapsLock & c:: {
    MarkCapsUsed()
    Send "^c"  ; Copy
}

CapsLock & v:: {
    MarkCapsUsed()
    Send "^v"  ; Paste
}

CapsLock & x:: {
    MarkCapsUsed()
    Send "^x"  ; Cut
}

; ============================================
; Window Control
; ============================================
CapsLock & w:: {
    MarkCapsUsed()
    Send "^w"  ; Close tab/window
}

CapsLock & q:: {
    MarkCapsUsed()
    Send "!{F4}"  ; Quit application (Alt+F4 on Windows)
}

CapsLock & Tab:: {
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send "+!{Tab}"  ; Switch windows reverse
    else
        Send "!{Tab}"  ; Switch windows
}

; ============================================
; App Shortcuts (Ctrl+Numbers)
; ============================================
CapsLock & 1:: {
    MarkCapsUsed()
    Send "^1"
}

CapsLock & 2:: {
    MarkCapsUsed()
    Send "^2"
}

CapsLock & 3:: {
    MarkCapsUsed()
    Send "^3"
}

CapsLock & 4:: {
    MarkCapsUsed()
    Send "^4"
}

CapsLock & 5:: {
    MarkCapsUsed()
    Send "^5"
}

CapsLock & 6:: {
    MarkCapsUsed()
    Send "^6"
}

CapsLock & 7:: {
    MarkCapsUsed()
    Send "^7"
}

CapsLock & 8:: {
    MarkCapsUsed()
    Send "^8"
}

CapsLock & 9:: {
    MarkCapsUsed()
    Send "^9"
}

CapsLock & 0:: {
    MarkCapsUsed()
    Send "^0"
}

; ============================================
; Language/Input Switcher
; ============================================
CapsLock & Space:: {
    MarkCapsUsed()
    Send "^{Space}"  ; Ctrl+Space (common for input switching)
}
