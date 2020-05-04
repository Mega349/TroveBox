main:
	Gosub, readTroveWindows

	oldPosMain[1] := HexToFloat(ReadMemory(xSkipAddress[1],PID,SkipSize)) ;Get current Main xPosition
	oldPosMain[2] := HexToFloat(ReadMemory(ySkipAddress[1],PID,SkipSize)) ;Get current Main yPosition
	oldPosMain[3] := HexToFloat(ReadMemory(zSkipAddress[1],PID,SkipSize)) ;Get current Main zPosition

	for account, PID in PIDArr
	{
		stuckTimeOutTimer[account] := addSecondsFromNow(stuckTimeOut)
	}

	while (TRUE)
	{
		for account, PID in PIDArr
		{
			if (account == 1) ;Main Part
			{
				;MsgBox,% "Main | " playernameArr[account]
				currentMainPos[1] := HexToFloat(ReadMemory(xSkipAddress[account],PID,SkipSize)) ;Get current Main xPosition
				currentMainPos[2] := HexToFloat(ReadMemory(ySkipAddress[account],PID,SkipSize)) ;Get current Main yPosition
				currentMainPos[3] := HexToFloat(ReadMemory(zSkipAddress[account],PID,SkipSize)) ;Get current Main zPosition

				if (!between(currentMainPos[1],oldPosMain[1]-posDisTrigger,oldPosMain[1]+posDisTrigger) || !between(currentMainPos[3],oldPosMain[3]-posDisTrigger,oldPosMain[3]+posDisTrigger))
				{
					oldPosMain[1] := currentMainPos[1] ;Backup current Main xPosition
					oldPosMain[2] := currentMainPos[2] ;Backup current Main yPosition
					oldPosMain[3] := currentMainPos[3] ;Backup current Main zPosition

					for account_, voidVar in PIDArr
					{
						if (account_ != 1)
						{
							positionArr[account_].push(ArraytoString(currentMainPos,1,splitDelimiter)) ;Append Main Position to the Position-Stack Array in the Array: "positionArr" for each Alt Account as String
						}
					}
				}
			}
			Else ;Alt Part
			{
				if (getTimeDifference(A_Now,stuckTimeOutTimer[account]) >=0 && !between(joinRequest[account],1,3))
				{
					joinRequest[account] := 1
				}
				Else if (positionArr[account].Length() == 0 && accIsMoving[account] == TRUE && getTimeDifference(A_Now,positionSyncDelay[account]) >=0) ;Stop Moving if Position-Stack is cleared and Player moved before
				{
					ControlSend, ahk_parent, {w up}, ahk_pid %PID%
					WriteProcessMemory(PID,xSkipAddress[account],ReadMemory(xSkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main xPos and force to Alt
					WriteProcessMemory(PID,ySkipAddress[account],ReadMemory(ySkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main yPos and force to Alt
					WriteProcessMemory(PID,zSkipAddress[account],ReadMemory(zSkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main zPos and force to Alt
					accIsMoving[account] := FALSE
					positionSyncDelay[account] := addSecondsFromNow(1)
				}
				Else if (positionArr[account].Length() != 0 && !between(joinRequest[account],1,3)) ;Move Account if Position-Stack is not empty
				{
					accIsMoving[account] := TRUE
					moveDone[account] := move(StrSplit(positionArr[account][1],"#")[1], StrSplit(positionArr[account][1],"#")[2], StrSplit(positionArr[account][1],"#")[3], PIDArr[account], account,moveTolerance,upSpeed,jumpDelay)
					if (moveDone[account])
					{
						positionArr[account].removeAt(1)
						stuckTimeOutTimer[account] := addSecondsFromNow(stuckTimeOut)
					}
				}
				Else if (joinRequest[account] == 1) ;Stop Moving if Teleport is requested
				{
					ControlSend, ahk_parent, {w up}, ahk_pid %PID%
					joinRequest[account] := 2
				}
				Else if (joinRequest[account] == 2) ;Teleport if requested (wait for Cooldown)
				{
					if (getTimeDifference(A_Now,teleportCooldown[account]) >=0)
					{
						ControlSend, ahk_parent, {o}, ahk_pid %PID%
						inviteJumpTime[account] := addSecondsFromNow(inviteJumpDelay)
						joinRequest[account] := 3
					}
				}
				Else if (joinRequest[account] == 3 && getTimeDifference(A_Now,inviteJumpTime[account]) >= 0) ;Validate Teleport
				{
					currentAltPos[1] := HexToFloat(ReadMemory(xSkipAddress[account],PID,SkipSize))
					currentAltPos[3] := HexToFloat(ReadMemory(zSkipAddress[account],PID,SkipSize))
					if (between(currentAltPos[1],currentMainPos[1]-joinMainDistanceStanding,currentMainPos[1]+joinMainDistanceStanding) && between(currentAltPos[3],currentMainPos[3]-joinMainDistanceStanding,currentMainPos[3]+joinMainDistanceStanding))
					{
						;if in %joinMainDistanceStanding% Block Range -> Main is not moving -> Sync Position and Jump after Teleport to close the Friend Overlay
						positionArr[account] := [] ;clear Position-Stack
						ControlSend, ahk_parent, {SPACE}, ahk_pid %PID%
						WriteProcessMemory(PID,xSkipAddress[account],ReadMemory(xSkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main xPos and force to Alt
						WriteProcessMemory(PID,ySkipAddress[account],ReadMemory(ySkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main yPos and force to Alt
						WriteProcessMemory(PID,zSkipAddress[account],ReadMemory(zSkipAddress[1],PIDArr[1],SkipSize),SkipSize) ;Read Main zPos and force to Alt
						teleportCooldown[account] := addSecondsFromNow(30) ;Trove Teleport Cooldown
						joinRequest[account] := 0
					}
					else if (between(currentAltPos[1],currentMainPos[1]-joinMainDistanceMoving,currentMainPos[1]+joinMainDistanceMoving) && between(currentAltPos[3],currentMainPos[3]-joinMainDistanceMoving,currentMainPos[3]+joinMainDistanceMoving))
					{
						;if in %joinMainDistanceMoving% Block Range -> Main is moving
						positionArr[account] := [] ;clear Position-Stack
						teleportCooldown[account] := addSecondsFromNow(30) ;Trove Teleport Cooldown
						positionArr[account].push(ArraytoString(currentMainPos,1,splitDelimiter)) ;add Main Position to Position Stack
						joinRequest[account] := 0
					}
					else
					{
						;if not in %joinMainDistanceMoving% Block Range -> Re-Teleport
						joinRequest[account] := 1
					}
				}
				else
				{
					stuckTimeOutTimer[account] := addSecondsFromNow(stuckTimeOut)
				}
			}
		}
	}
return

tempFunction:
	WinActivateBottom, ahk_exe Trove.exe
return
