;------------------------
;Pressed Hotkeys:
;------------------------

;------------------------
;Subs for Hotkeys at GUI:
;------------------------

InitHotkeys:
If !A_IsCompiled
{
    Hotkey, F1, Restart
    Hotkey, F2, ExitScript
}
;Hotkey, F3, main
Hotkey, F4, tempFunction
Hotkey, F5, requestJoin
return
