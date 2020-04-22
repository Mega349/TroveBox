;------------------------
;Own Functions:
;------------------------

ArraytoString(Array,counter = 0,delimiter = ",") ;(Array,Start-position,Delimiter)
{
	String := Array[counter]
	while (counter < Array.Length())
	{
		counter++
		String := String delimiter Array[counter]
	}
	return String
}

between(var,min,max)
{
	if (var >= min && var <= max)
	{
		return TRUE
	}
	else
	{
		return FALSE
	}
}

ReadStringFromMemory(Address, pid)
{
	string := ""
	AoB := []
	i := 0
	while (AoB[i-1] != 0 || i == 0) 
	{
    	AoB[i] := ReadMemory(Address+i, pid, 1)
		string := string chr(AoB[i])
		i++
	}
    return string
}

ReadFiletoArray(file) ;Index 0 = Amount of lines | Index 1 = line 1 etc...
{
    Array := []
    line = 0
    counter := 0

    fileObjekt := FileOpen(file, "r")
    while (line != "")
    {
        counter++
        line := fileObjekt.ReadLine()

        if (line != "")
        {
            Array[counter] := RTrim(line,"`n")
        }
    }
    Array[0] := Array.Length()
    fileObjekt.Close()

    return Array
}

ExitFunktion()
{
	Gosub, ExitScript
}

;------------------------
;Global Functions:
;------------------------

viewToCoord(pid,xDesPos,zDesPos,account)
{
	oneRotation := 6.28 ; from S to S
	cViewNewHight :=  0 ; Forced View Hight
	PI := 4*ATan(1)

	xCurrentPos := HexToFloat(ReadMemory(xSkipAddress[account],pid,SkipSize))
	zCurrentPos := HexToFloat(ReadMemory(zSkipAddress[account],pid,SkipSize))
	xCurrentView := HexToFloat(ReadMemory(xViewAddress[account],pid,ViewSize))
	zCurrentView := HexToFloat(ReadMemory(zViewAddress[account],pid,ViewSize))
	cViewCurrentWidth := HexToFloat(ReadMemory(cViewWidthAddress[account],pid,cViewSize))

	;Vector 1 (calculated)
    v1x1 := xCurrentPos - ((xCurrentView * 1) + xCurrentPos)
    v1x2 := zCurrentPos - ((zCurrentView * 1) + zCurrentPos)

	;Vector 2
    v2x1 := xCurrentPos - xDesPos
    v2x2 := zCurrentPos - zDesPos

	orient := v1x1 * v2x2 - v1x2 * v2x1

    radian := ACos(((v1x1 * v2x1) + (v1x2 * v2x2)) / ((Sqrt( (v1x1 ** 2) + (v1x2 ** 2))) * (Sqrt(((v2x1 ** 2) + (v2x2 ** 2))))))
    degree := radian * (180/PI)
    cViewDiffWidth := oneRotation / 360 * degree

    if (orient > 0)
    {
        cViewNewWidth := cViewCurrentWidth - cViewDiffWidth
    }
    Else
    {
        cViewNewWidth := cViewCurrentWidth + cViewDiffWidth
    }
	
	sleep, 15

	WriteProcessMemory(pid,cViewWidthAddress[account],FloatToHex(cViewNewWidth),cViewSize)
	WriteProcessMemory(pid,cViewHightAddress[account],FloatToHex(cViewNewHight),cViewSize)
}

getPointerAddress(PIDArray,IDArray)
{
	for key, PID in PIDArray
	{
		ProcessBase := getProcessBaseAddress(IDArray[key])

		xSkipAddress[key] := GetAddress(PID, ProcessBase, SkipBase, xSkipOffsetString)
		ySkipAddress[key] := GetAddress(PID, ProcessBase, SkipBase, ySkipOffsetString)
		zSkipAddress[key] := GetAddress(PID, ProcessBase, SkipBase, zSkipOffsetString)

		xAccelerationAddress[key] := GetAddress(PID, ProcessBase, AccelerationBase, xAccelerationOffsetString)
		yAccelerationAddress[key] := GetAddress(PID, ProcessBase, AccelerationBase, yAccelerationOffsetString)
		zAccelerationAddress[key] := GetAddress(PID, ProcessBase, AccelerationBase, zAccelerationOffsetString)

		xViewAddress[key] := GetAddress(PID, ProcessBase, ViewBase, xViewOffsetString)
		yViewAddress[key] := GetAddress(PID, ProcessBase, ViewBase, yViewOffsetString)
		zViewAddress[key] := GetAddress(PID, ProcessBase, ViewBase, zViewOffsetString)

		SpeedAddress[key] := GetAddress(PID, ProcessBase, SpeedBase, SpeedOffsetString)

		currentCDAdress[key] := GetAddress(PID, ProcessBase, CDBase, currentCDOffsetString)
		minCDAdress[key] := GetAddress(PID, ProcessBase, CDBase, minCDOffsetString)
		maxCDAdress[key] := GetAddress(PID, ProcessBase, CDBase, maxCDOffsetString)

		PlayernameAddress[key] := GetAddress(PID, ProcessBase, PlayernameBase, PlayernameOffsetString)

		cViewHightAddress[key] := GetAddress(PID, ProcessBase, cViewBase, cViewHightString)
		cViewWidthAddress[key] := GetAddress(PID, ProcessBase, cViewBase, cViewWidthString)
	}
}

;------------------------
;other Functions:
;------------------------


getProcessBaseAddress(Handle)
{
	Return DllCall( A_PtrSize = 4
	? "GetWindowLong"
	: "GetWindowLongPtr"
    , "Ptr", Handle
    , "Int", -6
    , "Int64")
}
	
GetAddress(PID, Base, Address, Offset)
{
	pointerBase := base + Address
	y := ReadMemory(pointerBase,PID)
	OffsetSplit := StrSplit(Offset, "+")
	OffsetCount := OffsetSplit.MaxIndex()
	Loop, %OffsetCount%
	{
		if (a_index = OffsetCount)
		{
			Address := (y + OffsetSplit[a_index])
		}
		Else if(a_index = 1) 
		{
			y := ReadMemory(y + OffsetSplit[a_index],PID)
		}
		Else
		{
			y := ReadMemory(y + OffsetSplit[a_index],PID)
		}
	}
	Return Address
}

ReadMemory(MADDRESS, pid, size = 4)
{
	VarSetCapacity(MVALUE,size,0)
	ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
	DllCall("ReadProcessMemory", "UInt", ProcessHandle, "Ptr", MADDRESS, "Ptr", &MVALUE, "Uint",size)
	Loop %size%
	result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
	Return, result
}

WriteProcessMemory(pid,address,wert, size = 4)
{
	VarSetCapacity(processhandle,32,0)
	VarSetCapacity(value, 32, 0)
	NumPut(wert,value,0,Uint)
	processhandle:=DllCall("OpenProcess","Uint",0x38,"int",0,"int",pid)
	Bvar:=DllCall("WriteProcessMemory","Uint",processhandle,"Uint",address+0,"Uint",&value,"Uint",size,"Uint",0)
}

HexToFloat(d)
{
	Return (1-2*(d>>31)) * (2**((d>>23 & 255)-127)) * (1+(d & 8388607)/8388608)
}

FloatToHex(f)
{
   form := A_FormatInteger
   SetFormat Integer, HEX
   v := DllCall("MulDiv", Float,f, Int,1, Int,1, UInt)
   SetFormat Integer, %form%
   Return v
}
