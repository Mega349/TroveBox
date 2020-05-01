loadINI:
if !FileExist(PointerFile)
{
	WritePointertoini(PointerFile)
}

if !FileExist(iniFile)
{
	IniWrite,1,%iniFile%,Version,ConfigVersion

	IniWrite,%PointerAutoUpdate%,%iniFile%,General,PointerAutoUpdate
	IniWrite,%EnableUpdateCheck%,%iniFile%,General,EnableUpdateCheck
	IniWrite,%ShowTooltip%,%iniFile%,General,ShowTooltip
}

;------------------------

if FileExist(PointerFile)
{
	ReadPointerfromini(PointerFile)
}

if FileExist(iniFile)
{
	IniRead,ConfigVersion,%iniFile%,Version,ConfigVersion

	Gosub, Updateini

	IniRead,PointerAutoUpdate,%iniFile%,General,PointerAutoUpdate
	IniRead,EnableUpdateCheck,%iniFile%,General,EnableUpdateCheck
	IniRead,ShowTooltip,%iniFile%,General,ShowTooltip
}
Return

WritePointertoini(ini)
{
	if (LastUpdateSupport != "ERROR")
	{
		IniWrite,%LastUpdateSupport%,%ini%,date,LastUpdateSupport

		IniWrite,%SkipSize%,%ini%,skip,Size 
		IniWrite,%SkipBase%,%ini%,skip,Base
		IniWrite,%xSkipOffsetString%,%ini%,skip,xOffsets
		IniWrite,%ySkipOffsetString%,%ini%,skip,yOffsets
		IniWrite,%zSkipOffsetString%,%ini%,skip,zOffsets

		IniWrite,%AccelerationSize%,%ini%,acceleration,Size
		IniWrite,%AccelerationBase%,%ini%,acceleration,Base
		IniWrite,%xAccelerationOffsetString%,%ini%,acceleration,xOffsets
		IniWrite,%yAccelerationOffsetString%,%ini%,acceleration,yOffsets
		IniWrite,%zAccelerationOffsetString%,%ini%,acceleration,zOffsets
		
		IniWrite,%ViewSize%,%ini%,view,Size
		IniWrite,%ViewBase%,%ini%,view,Base
		IniWrite,%xViewOffsetString%,%ini%,view,xOffsets
		IniWrite,%yViewOffsetString%,%ini%,view,yOffsets
		IniWrite,%zViewOffsetString%,%ini%,view,zOffsets
		
		IniWrite,%SpeedSize%,%ini%,speed,Size
		IniWrite,%SpeedBase%,%ini%,speed,Base
		IniWrite,%SpeedOffsetString%,%ini%,speed,Offsets
		
		IniWrite,%CDBase%,%ini%,camera_Distance,Size
		IniWrite,%CDBase%,%ini%,camera_Distance,Base
		IniWrite,%minCDOffsetString%,%ini%,camera_Distance,minOffset
		IniWrite,%maxCDOffsetString%,%ini%,camera_Distance,maxOffset
		
		IniWrite,%PlayernameSize%,%ini%,playername,Size
		IniWrite,%PlayernameBase%,%ini%,playername,Base
		IniWrite,%PlayernameOffsetString%,%ini%,playername,Offsets

		IniWrite,%cViewSize%,%ini%,cView,Size
		IniWrite,%cViewBase%,%ini%,cView,Base
		IniWrite,%cViewHightSOffsetString%,%ini%,cView,Hight
		IniWrite,%cViewWidthOffsetString%,%ini%,cView,Width

		IniWrite,%accountIdSize%,%ini%,accountId,Size
		IniWrite,%accountIdbase%,%ini%,accountId,Base
		IniWrite,%accountIdOffsetString%,%ini%,accountId,Offsets

		state := TRUE
	}
	else
	{
		state := FALSE
	}
	
	return state
}

ReadPointerfromini(ini)
{
	IniRead,LastUpdateSupport,%ini%,date,LastUpdateSupport

	IniRead,SkipSize,%ini%,skip,Size 
	IniRead,SkipBase,%ini%,skip,Base
	IniRead,xSkipOffsetString,%ini%,skip,xOffsets
	IniRead,ySkipOffsetString,%ini%,skip,yOffsets
	IniRead,zSkipOffsetString,%ini%,skip,zOffsets

	IniRead,AccelerationSize,%ini%,acceleration,Size
	IniRead,AccelerationBase,%ini%,acceleration,Base
	IniRead,xAccelerationOffsetString,%ini%,acceleration,xOffsets
	IniRead,yAccelerationOffsetString,%ini%,acceleration,yOffsets
	IniRead,zAccelerationOffsetString,%ini%,acceleration,zOffsets
	
	IniRead,ViewSize,%ini%,view,Size
	IniRead,ViewBase,%ini%,view,Base
	IniRead,xViewOffsetString,%ini%,view,xOffsets
	IniRead,yViewOffsetString,%ini%,view,yOffsets
	IniRead,zViewOffsetString,%ini%,view,zOffsets
	
	IniRead,SpeedSize,%ini%,speed,Size
	IniRead,SpeedBase,%ini%,speed,Base
	IniRead,SpeedOffsetString,%ini%,speed,Offsets
	
	IniRead,CDBase,%ini%,camera_Distance,Size
	IniRead,CDBase,%ini%,camera_Distance,Base
	IniRead,minCDOffsetString,%ini%,camera_Distance,minOffset
	IniRead,maxCDOffsetString,%ini%,camera_Distance,maxOffset
	
	IniRead,PlayernameSize,%ini%,playername,Size
	IniRead,PlayernameBase,%ini%,playername,Base
	IniRead,PlayernameOffsetString,%ini%,playername,Offsets

	IniRead,cViewSize,%ini%,cView,Size
	IniRead,cViewBase,%ini%,cView,Base
	IniRead,cViewHightSOffsetString,%ini%,cView,Hight
	IniRead,cViewWidthOffsetString,%ini%,cView,Width

	IniRead,accountIdSize,%ini%,accountId,Size
	IniRead,accountIdbase,%ini%,accountId,Base
	IniRead,accountIdOffsetString,%ini%,accountId,Offsets
}

Updateini:
/*
if (ConfigVersion < 2 || ConfigVersion == "" || ConfigVersion == "ERROR")
{
	ConfigVersion := 2
	IniWrite,%ConfigVersion%,%iniFile%,Version,ConfigVersion
}
*/
return
