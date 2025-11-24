; SuperKeys Placeholder for AutoHotkey
; CapsLock becomes Escape when tapped, Control when held

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

*CapsLock::
    Send {Blind}{Ctrl Down}
    KeyWait, CapsLock
    Send {Blind}{Ctrl Up}
    if (A_PriorKey = "CapsLock")
    {
        Send {Escape}
    }
return
