readTroveWindows:
WinGet, IDArrP, List, ahk_exe Trove.exe

accCounter := IDArrP
while (accCounter >= 1)
{
	IDArr[accCounter] := IDArrP%accCounter%
	WinGet, currentPID, PID,% "ahk_id" IDArr[accCounter]
	PIDArr[accCounter] := currentPID

	positionArr.push([]) ;Append empty Array for each Account to this Array (reverse but this dont care ^^)

	accCounter--
}

getPointerAddress(PIDArr,IDArr)

for index_, PID_ in PIDArr
{
	playernameArr[index_] := ReadStringFromMemory(PlayernameAddress[index_],PID_)
	if (index_ == 1)
	{
		;WinSetTitle, ahk_pid %PID_%, ,% "PID: " PID_ " | " playernameArr[index_] " (Main)"
		WinSetTitle, ahk_pid %PID_%, ,% playernameArr[index_] " (Main)"
	}
	else
	{
		;WinSetTitle, ahk_pid %PID_%, ,% "PID: " PID_ " | " playernameArr[index_]
		WinSetTitle, ahk_pid %PID_%, ,% playernameArr[index_]
	}
	
}

return

Save:
return

GuiClose:
ExitApp

Restart:
Run %A_ScriptFullPath%
ExitApp

ExitScript: ;called through "ExitFunktion()" use "ExitApp" to run that code on exit.
;code...
ExitApp

;------------------------
;SetTimer Subs:
;------------------------

ToolTip:
if (WinActive("ahk_exe Trove.exe") && ShowTooltip == 1)
{
    ToolTipString := "PID = " PIDArr[2]

	ToolTipString := ToolTipString "`n" positionArr[2].Length()

	ToolTip, %ToolTipString%, 0, 0, 1
}
else
{
	ToolTip,,,,1
}
return

