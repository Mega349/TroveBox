readTroveWindows:
	SplashTextOn,200,25,% ScriptName " v" ScriptVersion,% "Reading account information..."

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
		memoryObjekt := new _ClassMemory("ahk_pid " PID_, "", hProcess) ;Create Memory Objekt

		mainIdAddress[index_] := memoryObjekt.processPatternScan(,, mainIdPattern*) ;Find String in Memory using Pattern (very slow!)
		AccountIdArr[index_] := ReadMemory(accountIdAddress[index_],PID_,accountIdSize) ;read AccountID
		memoryObjekt.writeString(mainIdAddress[index_], AccountIdArr[1]) ;Write Main AccountID to all Accounts

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

	SplashTextOff
return

requestJoin:
	for _i, voidVar in PIDArr
	{
		joinRequest[_i] := 1
	}
return

Save:
return

GuiClose:
ExitApp

Restart:
	Run %A_ScriptFullPath%
ExitApp

ExitScript: ;called through "ExitFunktion()" use "ExitApp" to run that code on exit. (the code will run twice idk why...)
	for PID in PIDArr
	{
		ControlSend, ahk_parent, {w up},ahk_pid %PID%
	}
ExitApp

;------------------------
;SetTimer Subs:
;------------------------

ToolTip:
	if (WinActive("ahk_exe Trove.exe") && ShowTooltip == 1)
	{
		ToolTipString := ""

		for accToolTip, PIDToolTip in PIDArr
		{
			if (accToolTip == 1)
			{
				ToolTipString := playernameArr[accToolTip] " (Main) | PID: " PIDToolTip
			}
			else
			{
				ToolTipString := ToolTipString "`n" playernameArr[accToolTip] " | PID: " PIDToolTip
				ToolTipString := ToolTipString " | Tasks:  " positionArr[accToolTip].Length()
				ToolTipString := ToolTipString " | Stuck Timeout: " getTimeDifference(A_Now,stuckTimeOutTimer[accToolTip]) * -1
				if !(getTimeDifference(A_Now,teleportCooldown[accToolTip]) >= 0)
				{
					ToolTipString := ToolTipString " | TP Cooldown: " getTimeDifference(A_Now,teleportCooldown[accToolTip]) * -1
				}
				if (joinRequest[accToolTip] > 0)
				{
					ToolTipString := ToolTipString " | Teleport requested " joinRequest[accToolTip] 
				}
			}
		}

		ToolTip, %ToolTipString%, 0, 0, 1
	}
	else
	{
		ToolTip,,,,1
	}
return
