; SuperKeys - Cross-platform Hyper Key Configuration
; Caps Lock as Hyper key with vim-style navigation
; AutoHotkey v1.1
;
; CapsLock: tap for Escape, hold for Hyper key

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Disable CapsLock for its normal functionality
SetCapsLockState, AlwaysOff

; Track whether CapsLock was used as modifier
global CapsUsedAsModifier := false

; CapsLock detection: tap for Escape, hold for Hyper
*CapsLock::
    CapsUsedAsModifier := false
    KeyWait, CapsLock
return

*CapsLock up::
    if (!CapsUsedAsModifier) {
        Send {Escape}
    }
    CapsUsedAsModifier := false
return

; Helper function to mark CapsLock as used with a key
MarkCapsUsed() {
    global CapsUsedAsModifier
    CapsUsedAsModifier := true
}

; ============================================
; Caps+Esc: Toggle CapsLock
; ============================================
CapsLock & Esc::
    MarkCapsUsed()
    SetCapsLockState % !GetKeyState("CapsLock", "T")
return

; ============================================
; Vim-style Navigation (HJKL)
; ============================================
CapsLock & h::
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send +{Left}
    else
        Send {Left}
return

CapsLock & j::
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send +{Down}
    else
        Send {Down}
return

CapsLock & k::
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send +{Up}
    else
        Send {Up}
return

CapsLock & l::
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send +{Right}
    else
        Send {Right}
return

; ============================================
; Word/Line/Page Navigation
; ============================================
CapsLock & a::
    MarkCapsUsed()
    Send ^{Left}  ; Word left
return

CapsLock & e::
    MarkCapsUsed()
    Send ^{Right}  ; Word right
return

CapsLock & u::
    MarkCapsUsed()
    Send {Home}  ; Line start
return

CapsLock & o::
    MarkCapsUsed()
    Send {End}  ; Line end
return

CapsLock & i::
    MarkCapsUsed()
    Send {End}  ; Line end (alternate)
return

CapsLock & d::
    MarkCapsUsed()
    Send {PgDn}  ; Page down
return

CapsLock & f::
    MarkCapsUsed()
    Send {PgUp}  ; Page up
return

; ============================================
; Deletion
; ============================================
CapsLock & n::
    MarkCapsUsed()
    Send ^{Backspace}  ; Delete word backward
return

CapsLock & m::
    MarkCapsUsed()
    Send {Backspace}  ; Delete char backward
return

CapsLock & ,::
    MarkCapsUsed()
    Send {Delete}  ; Delete char forward
return

CapsLock & .::
    MarkCapsUsed()
    Send ^{Delete}  ; Delete word forward
return

; ============================================
; Clipboard (Cut/Copy/Paste)
; ============================================
CapsLock & c::
    MarkCapsUsed()
    Send ^c  ; Copy
return

CapsLock & v::
    MarkCapsUsed()
    Send ^v  ; Paste
return

CapsLock & x::
    MarkCapsUsed()
    Send ^x  ; Cut
return

; ============================================
; Window Control
; ============================================
CapsLock & w::
    MarkCapsUsed()
    Send ^w  ; Close tab/window
return

CapsLock & q::
    MarkCapsUsed()
    Send !{F4}  ; Quit application (Alt+F4 on Windows)
return

CapsLock & Tab::
    MarkCapsUsed()
    if GetKeyState("Shift")
        Send +!{Tab}  ; Switch windows reverse
    else
        Send !{Tab}  ; Switch windows
return

; ============================================
; App Shortcuts (Ctrl+Numbers)
; ============================================
CapsLock & 1::
    MarkCapsUsed()
    Send ^1
return

CapsLock & 2::
    MarkCapsUsed()
    Send ^2
return

CapsLock & 3::
    MarkCapsUsed()
    Send ^3
return

CapsLock & 4::
    MarkCapsUsed()
    Send ^4
return

CapsLock & 5::
    MarkCapsUsed()
    Send ^5
return

CapsLock & 6::
    MarkCapsUsed()
    Send ^6
return

CapsLock & 7::
    MarkCapsUsed()
    Send ^7
return

CapsLock & 8::
    MarkCapsUsed()
    Send ^8
return

CapsLock & 9::
    MarkCapsUsed()
    Send ^9
return

CapsLock & 0::
    MarkCapsUsed()
    Send ^0
return

; ============================================
; Language/Input Switcher
; ============================================
CapsLock & Space::
    MarkCapsUsed()
    Send ^{Space}  ; Ctrl+Space (common for input switching)
return
