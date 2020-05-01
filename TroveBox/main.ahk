main:
	Gosub, readTroveWindows

	oldPosMain[1] := HexToFloat(ReadMemory(xSkipAddress[1],PID,SkipSize)) ;Get current Main xPosition
	oldPosMain[2] := HexToFloat(ReadMemory(ySkipAddress[1],PID,SkipSize)) ;Get current Main yPosition
	oldPosMain[3] := HexToFloat(ReadMemory(zSkipAddress[1],PID,SkipSize)) ;Get current Main zPosition

	while (TRUE)
	{
		for account, PID in PIDArr
		{
			if (account == 1) ;Main Part
			{
				;MsgBox,% "Main | " playernameArr[account]
				currentPosMain[1] := HexToFloat(ReadMemory(xSkipAddress[account],PID,SkipSize)) ;Get current Main xPosition
				currentPosMain[2] := HexToFloat(ReadMemory(ySkipAddress[account],PID,SkipSize)) ;Get current Main yPosition
				currentPosMain[3] := HexToFloat(ReadMemory(zSkipAddress[account],PID,SkipSize)) ;Get current Main zPosition

				if (!between(currentPosMain[1],oldPosMain[1]-posDisTrigger,oldPosMain[1]+posDisTrigger) || !between(currentPosMain[3],oldPosMain[3]-posDisTrigger,oldPosMain[3]+posDisTrigger))
				{
					oldPosMain[1] := currentPosMain[1] ;Backup current Main xPosition
					oldPosMain[2] := currentPosMain[2] ;Backup current Main yPosition
					oldPosMain[3] := currentPosMain[3] ;Backup current Main zPosition

					for account_, voidVar in PIDArr
					{
						if (account_ != 1)
						{
							positionArr[account_].push(ArraytoString(currentPosMain,1,splitDelimiter)) ;Append Main Position to the Position Stack Array in the Array: "positionArr" for each Alt Account as String
						}
					}
				}
			}
			Else ;Alt Part
			{
				if (positionArr[account].Length() == 0 && accIsMoving[account] == TRUE)
				{
					ControlSend, ahk_parent, {w up}, ahk_pid %PID%
					WriteProcessMemory(PID,xSkipAddress[account],ReadMemory(xSkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main xPos and force to Alt
					WriteProcessMemory(PID,ySkipAddress[account],ReadMemory(ySkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main yPos and force to Alt
					WriteProcessMemory(PID,zSkipAddress[account],ReadMemory(zSkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main zPos and force to Alt
					accIsMoving[account] := FALSE
				}
				Else if (positionArr[account].Length() != 0)
				{
					accIsMoving[account] := TRUE
					moveDone[account] := move(StrSplit(positionArr[account][1],"#")[1], StrSplit(positionArr[account][1],"#")[2], StrSplit(positionArr[account][1],"#")[3], PIDArr[account], account,moveTolerance,upSpeed,jumpDelay)
					if (moveDone[account])
					{
						positionArr[account].removeAt(1)
					}
				}
			}
		}
	}
return

tempFunction:
	WinActivateBottom, ahk_exe Trove.exe
return
