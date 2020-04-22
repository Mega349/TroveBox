main:
	Gosub, readTroveWindows

	oldPosMain[1] := HexToFloat(ReadMemory(xSkipAddress[1],PID,SkipSize)) ;Save current Main xPosition
	oldPosMain[2] := HexToFloat(ReadMemory(ySkipAddress[1],PID,SkipSize)) ;Save current Main yPosition
	oldPosMain[3] := HexToFloat(ReadMemory(zSkipAddress[1],PID,SkipSize)) ;Save current Main zPosition

	while (TRUE)
	{
		for account, PID in PIDArr
		{
			if (account == 1) ;Main Part
			{
				;MsgBox,% "Main | " playernameArr[account]
				currentPosMain[1] := HexToFloat(ReadMemory(xSkipAddress[account],PID,SkipSize)) ;Save current Main xPosition
				currentPosMain[2] := HexToFloat(ReadMemory(ySkipAddress[account],PID,SkipSize)) ;Save current Main yPosition
				currentPosMain[3] := HexToFloat(ReadMemory(zSkipAddress[account],PID,SkipSize)) ;Save current Main zPosition

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
				msgboxString := playernameArr[account]
				msgboxString := msgboxString "`n1 | " positionArr[account][1]
				msgboxString := msgboxString "`n2 | " positionArr[account][2]
				msgboxString := msgboxString "`n3 | " positionArr[account][3]
				msgboxString := msgboxString "`n4 | " positionArr[account][4]
				msgboxString := msgboxString "`n5 | " positionArr[account][5]
				msgboxString := msgboxString "`n6 | " positionArr[account][6]
				msgboxString := msgboxString "`n7 | " positionArr[account][7]
				msgboxString := msgboxString "`n8 | " positionArr[account][8]
				msgboxString := msgboxString "`n9 | " positionArr[account][9]
				msgboxString := msgboxString "`n10 | " positionArr[account][10]
				msgboxString := msgboxString "`n11 | " positionArr[account][11]
				msgboxString := msgboxString "`n12 | " positionArr[account][12]

				;MsgBox,% msgboxString

				if(move(StrSplit(positionArr[account][1],"#")[1], StrSplit(positionArr[account][1],"#")[2], StrSplit(positionArr[account][1],"#")[3], PIDArr[account], account))
				{
					positionArr[account].removeAt(1)
				}
			}
		}
	}
return

/*
viewToCoord:
	while (TRUE)
	{
		for account, PID in PIDArr
		{
			sleep, 50
			viewToCoord(PID,82.5,-40.5,account)
		}
	}
return
*/

test:
WinActivateBottom, ahk_exe Trove.exe
return

move(x,y,z,pid,account)
{
	toleranz := 0.5
	currentPos := []

	currentPos[1] := HexToFloat(ReadMemory(xSkipAddress[account],pid,SkipSize)) ;Save current Main xPosition
	currentPos[2] := HexToFloat(ReadMemory(ySkipAddress[account],pid,SkipSize)) ;Save current Main yPosition
	currentPos[3] := HexToFloat(ReadMemory(zSkipAddress[account],pid,SkipSize)) ;Save current Main zPosition

	viewToCoord(pid,x,z,account)

	ControlSend, ahk_parent, {w down}, ahk_pid %pid%

	if (between(currentPos[1], x-toleranz, x+toleranz) && between(currentPos[3], z-toleranz, z+toleranz))
	{
		ControlSend, ahk_parent, {w up}, ahk_pid %pid%
		return true
	}
	return false
}
