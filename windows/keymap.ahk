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

; Disable CapsLock LED/toggle state
SetCapsLockState "AlwaysOff"

; ============================================
; CapsLock Press/Release Handling
; ============================================
; Matches keyd's overload() semantics: Escape fires on release only if no
; other key was pressed while CapsLock was held - no time limit. A_PriorKey
; still equals "CapsLock" at release time iff nothing else was pressed.
*CapsLock:: {
}

*CapsLock up:: {
    if (A_PriorKey = "CapsLock")
        Send "{Escape}"
}

; ============================================
; Context: CapsLock is physically held down
; ============================================
#HotIf GetKeyState("CapsLock", "P")

; --- Toggle real CapsLock ---
Esc:: {
    SetCapsLockState !GetKeyState("CapsLock", "T")
}

; --- Vim Navigation (HJKL) ---
; {Blind} lets held modifiers fall through: Shift selects, Ctrl jumps words,
; matching keyd's `fallthrough = true`.
*h:: Send "{Blind}{Left}"
*j:: Send "{Blind}{Down}"
*k:: Send "{Blind}{Up}"
*l:: Send "{Blind}{Right}"

; --- Word/Line/Page Navigation (Shift falls through for selection) ---
*a:: Send "{Blind}^{Left}"   ; Word left
*e:: Send "{Blind}^{Right}"  ; Word right
*u:: Send "{Blind}{Home}"    ; Line start
*o:: Send "{Blind}{End}"     ; Line end
*d:: Send "{Blind}{PgDn}"    ; Page down
*f:: Send "{Blind}{PgUp}"    ; Page up

; --- Editing ---
i:: Send "^a"    ; Select all
z:: Send "^z"    ; Undo
+z:: Send "^+z"  ; Redo
/:: Send "^f"    ; Find

; --- Deletion ---
n:: Send "^{Backspace}"  ; Delete word backward
m:: Send "{Backspace}"   ; Delete char backward
,:: Send "{Delete}"      ; Delete char forward
.:: Send "^{Delete}"     ; Delete word forward

; --- Clipboard ---
c:: Send "^c"  ; Copy
v:: Send "^v"  ; Paste
x:: Send "^x"  ; Cut

; --- Window Control ---
w:: Send "^w"     ; Close tab/window
q:: Send "!{F4}"  ; Quit application
Tab:: Send "!{Tab}"    ; Switch windows
+Tab:: Send "+!{Tab}"  ; Switch windows (reverse)

; --- Tab Cycling ---
[:: Send "^+{Tab}"  ; Previous tab
]:: Send "^{Tab}"   ; Next tab

; --- Terminal Shortcuts ---
Enter:: Send "^{Enter}"

; --- App Shortcuts (Ctrl+Number, Ctrl+G/R/T) ---
1:: Send "^1"
2:: Send "^2"
3:: Send "^3"
4:: Send "^4"
5:: Send "^5"
6:: Send "^6"
7:: Send "^7"
8:: Send "^8"
9:: Send "^9"
0:: Send "^0"
g:: Send "^g"
r:: Send "^r"
t:: Send "^t"

; --- Language/Input Switcher ---
Space:: Send "^{Space}"
!Space:: Send "^!{Space}"

#HotIf  ; End CapsLock context
