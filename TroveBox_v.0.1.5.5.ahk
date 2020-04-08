#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Input
#SingleInstance force
#WinActivateForce
SetTitleMatchMode, 3
;#IfWinActive,ahk_exe Trove.exe

;------------------------
;variable:
;------------------------

;File / Name / Location Vars
TempPointerFile = %A_Temp%\Trove_Pointer.ini
PointerHostFile := "https://webtrash.lima-city.de/Trove_Pointer_Host.ini"
global iniFile := "TroveBox.ini"
PointerFile := "Pointer.ini"
global ScriptName := "TroveBox"

;Config blank Pattern
global LastUpdateSupport := "01.01.2000"

global SkipBase := "0x00000000"

global xSkipOffsetString := "0x0+0x0+0x0+0x0+0x0"
global ySkipOffsetString := "0x0+0x0+0x0+0x0+0x0"
global zSkipOffsetString := "0x0+0x0+0x0+0x0+0x0"

;Config Vars
PointerAutoUpdate := 1
DistanceToMain := 2.25
DistancePerStep := 0.5
DelayBetweenSteps := 20

;Internal Vars
AccPID := []
xAddress := []
yAddress := []
zAddress := []
WindowAmount := 0
DistanceToMainZero := 0

;------------------------
;Admin Check:
;------------------------

if !A_IsAdmin
{
	try
	{
		Run *RunAs "%A_ScriptFullPath%"
		ExitApp
	}
	gosub, ExitScript
}

;------------------------
;Create and Read INI File:
;------------------------

if !FileExist(PointerFile)
{
	WritePointertoini(PointerFile)
}

if !FileExist(iniFile)
{
	erststart := 1
	IniWrite,1,%iniFile%,Version,ConfigVersion
	IniWrite,%DistanceToMain%,%iniFile%,Distance,DistanceToMain
	IniWrite,%DistancePerStep%,%iniFile%,Distance,DistancePerStep
	IniWrite,%DelayBetweenSteps%,%iniFile%,Time,DelayBetweenSteps
	IniWrite,%PointerAutoUpdate%,%iniFile%,AutoUpdate,PointerAutoUpdate
}

;------------------------

if FileExist(PointerFile)
{
	ReadPointerfromini(PointerFile)
}

if FileExist(iniFile)
{
	IniRead,ConfigVersion,%iniFile%,Version,ConfigVersion
	IniRead,DistanceToMain,%iniFile%,Distance,DistanceToMain
	IniRead,DistancePerStep,%iniFile%,Distance,DistancePerStep
	IniRead,DelayBetweenSteps,%iniFile%,Time,DelayBetweenSteps
	IniRead,PointerAutoUpdate,%iniFile%,AutoUpdate,PointerAutoUpdate
	
	if(erststart != 1)
	{	
		TrayTip,%ScriptName%,%iniFile% wurde geladen!
	}
	else if(erststart == 1)
	{	
		TrayTip,%ScriptName%,%iniFile% wurde erstellt!
	}

	;------------------------ (für nachträgliche änderungen in der ini (kopie))

	;if(ConfigVersion < 2 || ConfigVersion == "" || ConfigVersion == "ERROR")
	;{
	;	ConfigVersion := 2
	;	IniWrite,%ConfigVersion%,%iniFile%,Version,ConfigVersion
	;	worldid := "Bitte ausfuellen"
	;	IniWrite,%worldid%,%iniFile%,World,lastid
	;}
}

;------------------------
;Auto Update:
;------------------------
if(PointerAutoUpdate == 1)
{
	try
	{
		UrlDownloadToFile, %PointerHostFile% , %TempPointerFile%
	}
	if FileExist(TempPointerFile)
	{
		ReadPointerfromini(TempPointerFile)
        WritePointertoini(PointerFile)
	    FileDelete,%TempPointerFile%
	}
}

;------------------------
;GUI:
;------------------------

Gui, -SysMenu
Gui,Add,Tab,w700 h262, Start|Einstellungen|Hotkeys
Gui,Show,,%A_ScriptName% | Trove Update Support = %LastUpdateSupport%

Gui,Tab,1
Gui, Add, Text,cblue, Das Skript befinden sich in der Testphase also sind buggs vorhanden!
Gui, Add, Text,cblue, Das Skript ist noch nicht fertig z.B. wird die "Y" Koordinate nicht beruecksichtigt!
Gui, Add, Text,cred, Die Alts werden werden nach 20min wegen inaktivitaet gekickt! also ab und zu rein wechseln!!!
Gui, Add, Text,cred, NICHT den Main schliessen wenn das Skript laeuft!
Gui, Add, Button,gResetINI , Reset %iniFile%
Gui, Add, Button,gUpdatecheck , Webseite aufrufen
Gui, Add, Button,gRestart , Neustarten
Gui, Add, Button,gExitScript , Beenden

Gui,Tab,2
Gui, Add, Text,, Abstand der zum Main eingehalten wird in bloecken:
Gui, Add, Text,, Bloecke pro Schritt (bewegungs Geschwindigkeit) (Max. = 4):
Gui, Add, Text,, 
Gui, Add, Text,, Verzoegerrung Zwischen Schritten in "ms" (Alle Alts werden schrittweise nacheinander bewegt!) (Min. = 1):
Gui, Add, Text,, 
if(PointerAutoUpdate == 1)
{
	Gui, Add, Checkbox,checked vPointerAutoUpdate gSave, Pointer Auto Update
}
else
{
	Gui, Add, Checkbox, vPointerAutoUpdate gSave, Pointer Auto Update
}
Gui, Add, Edit, xs+520 ys30 r1 vDistanceToMain gSave w150, %DistanceToMain%
Gui, Add, Edit, r1 vDistancePerStep gSave w150, %DistancePerStep%
Gui, Add, Text,, 
Gui, Add, Edit, r1 vDelayBetweenSteps gSave w150, %DelayBetweenSteps%

Gui,Tab,3
Gui, Add, Text,, Strg+S = Start
Gui, Add, Text,, Strg+P = Skript pausieren
Gui, Add, Text,, Strg+T = Skript beenden
Gui, Add, Text,, Strg+R = Trove Fenster erkennen
Gui, Add, Text,, Strg+W = Distanz zu Main umschalten zwischen "0" und "eingestellter Wert" (fuer z.B. enge Passagen!)

;------------------------
;End Startup:
;------------------------

return

;------------------------
;Hotkeys:
;------------------------

^S::
gosub, Main
return

^R::
gosub, CheckAccs
return

^P::
loop := 0
return

^W::
gosub, SwitchDistanceToMain
return

^T::
gosub, ExitScript

;------------------------
;Subroutine:
;------------------------

Main:
;CheckDelay
if DelayBetweenSteps is integer
{
	if(DelayBetweenSteps >= 1)
	{
		DelayBetweenStepsChecked := DelayBetweenSteps
	}
	else
	{
		DelayBetweenStepsChecked := 1	;ohne ein delay wäre es CPU abhängig -> Schlecht
		TrayTip,%ScriptName%, Die eingestellte Verzoegerrung "%DelayBetweenSteps%" ist zu klein! daher wird nun "1" genutzt!
		DelayBetweenSteps := DelayBetweenStepsChecked
		gosub, RefreshGUI
		IniWrite,1,%iniFile%,Time,DelayBetweenSteps
	}
}
else
{
	msgbox, Deine eingestellte Verzoegerrung darf nur aus Ganzzahlen (Integer) bestehen! (z.B. "5" oder "120")
	return
}
;CheckAccs
if(WindowAmount == 0)
{
	gosub, CheckAccs
}
if(WindowAmount <= 1)
{
	msgbox, Es wurden zu wenig Trove Fenster gefunden bitte starte deine Accounts und druecke Strg + R!
	return
}
;Start
TrayTip,%ScriptName%, Skript gestartet!
counter := 1
loop := 1
while(loop == 1)
{
	while(WindowAmount > counter)
	{
		;Get Main Pos.
		xPosMain := HexToFloat(ReadMemory(xAddress[0], AccPID[0]))
		yPosMain := HexToFloat(ReadMemory(yAddress[0], AccPID[0]))
		zPosMain := HexToFloat(ReadMemory(zAddress[0], AccPID[0]))
		;Get Alt Pos.
		xPosAlt := HexToFloat(ReadMemory(xAddress[counter], AccPID[counter]))
		yPosAlt := HexToFloat(ReadMemory(yAddress[counter], AccPID[counter]))
		zPosAlt := HexToFloat(ReadMemory(zAddress[counter], AccPID[counter]))
		;DistanceToMain (zero)
		if(DistanceToMainZero == 1)
		{
			DistanceToMainTemp := 0
		}
		else if(DistanceToMainZero == 0)
		{
			DistanceToMainTemp := DistanceToMain
		}
		;Movement
		FollowMain(AccPID[counter], xAddress[counter], xPosMain, xPosAlt, DistancePerStep, DistanceToMainTemp)
		FollowMain(AccPID[counter], zAddress[counter], zPosMain, zPosAlt, DistancePerStep, DistanceToMainTemp)
		;Other
		counter++
		sleep, DelayBetweenStepsChecked
	}
	counter := 1
}
TrayTip,%ScriptName%, Skript  pausiert! | Strg+S = Start
return

RefreshGUI:
GuiControl,Text, DelayBetweenSteps, %DelayBetweenSteps%
return

SwitchDistanceToMain:
if(DistanceToMainZero == 0)
{
	DistanceToMainZero := 1
	TrayTip,%ScriptName%, Distance zu Main ist nun "0"!
}
else if(DistanceToMainZero == 1)
{
	TrayTip,%ScriptName%, Distance zu Main ist nun "%DistanceToMain%"!
	DistanceToMainZero := 0
}
return

CheckAccs:
counterCA := 0
PIDMain := -1
if(WinExist("Trove") == "0x0")
{
	WindowAmount := 0
}
else
{
	WinActivate, Trove ahk_class SDL_app
	while(PIDMain != PID) ;Schleife 1x zu oft daher bei 3 Fenstern AccPID[3] = AccPID[0] aber AccPID[3] ungenutzt
	{
		WinGet, PID, PID, Trove
		WinGet, hwnd, ID, Trove
		Base := getProcessBaseAddress(hwnd)
		xAddress[counterCA] := GetAddress(PID, Base, SkipBase, xSkipOffsetString)
		yAddress[counterCA] := GetAddress(PID, Base, SkipBase, ySkipOffsetString)
		zAddress[counterCA] := GetAddress(PID, Base, SkipBase, zSkipOffsetString)
		AccPID[counterCA] := PID
		if(counterCA == 1)
		{
			PIDMain := AccPID[0]
		}	
		if(PIDMain != PID)
		{
			WinActivateBottom, Trove ahk_class SDL_app
		}
		WindowAmount := counterCA
		counterCA++
		sleep, 10
	}
}
TrayTip,%ScriptName%, Es wurden "%WindowAmount%" Trove Fenster gefunden!
return

Updatecheck:
Run https://webtrash.lima-city.de/
return

ResetINI:
FileDelete,%iniFile%

Restart:
Run "%A_ScriptFullPath%"

ExitScript:
TrayTip,%ScriptName%, Skript beendet!
ExitApp

Save:
GuiControlGet,DistanceToMain,,DistanceToMain
GuiControlGet,DistancePerStep,,DistancePerStep
GuiControlGet,DelayBetweenSteps,,DelayBetweenSteps
GuiControlGet,PointerAutoUpdate,,PointerAutoUpdate

IniWrite,%DistanceToMain%,%iniFile%,Distance,DistanceToMain
IniWrite,%DistancePerStep%,%iniFile%,Distance,DistancePerStep
IniWrite,%DelayBetweenSteps%,%iniFile%,Time,DelayBetweenSteps
IniWrite,%PointerAutoUpdate%,%iniFile%,AutoUpdate,PointerAutoUpdate
return

;------------------------
;Own Functions:
;------------------------

WritePointertoini(ini)
{
	IniWrite,%LastUpdateSupport%,%ini%,Date,LastUpdateSupport
	IniWrite,%SkipBase%,%ini%,Skip,Base
	IniWrite,%xSkipOffsetString%,%ini%,Skip,xOffsets
	IniWrite,%ySkipOffsetString%,%ini%,Skip,yOffsets
	IniWrite,%zSkipOffsetString%,%ini%,Skip,zOffsets
}

ReadPointerfromini(ini)
{
	IniRead,LastUpdateSupport,%ini%,Date,LastUpdateSupport
	IniRead,SkipBase,%ini%,Skip,Base
	IniRead,xSkipOffsetString,%ini%,Skip,xOffsets
	IniRead,ySkipOffsetString,%ini%,Skip,yOffsets
	IniRead,zSkipOffsetString,%ini%,Skip,zOffsets
}

FollowMain(pid,address,mainvalue,value,distance,distancetomain)
{
	if(mainvalue > value)
	{
		if(distancetomain > 0)
		{
			mainvalue := mainvalue - distancetomain
		}
	
		difference :=  mainvalue - value
		
		if(difference < distance)
		{
			value := value + difference
		}
		else
		{
			value := value + distance
		}
	}
	else if(mainvalue < value)
	{
		if(distancetomain > 0)
		{
			mainvalue := mainvalue + distancetomain
		}
	
		difference := value - mainvalue

		if(difference < distance)
		{
			value := value - difference
		}
		else
		{
			value := value - distance
		}
	}
	WriteProcessMemory(pid, address, FloatToHex(value))
	;else if(mainvalue == value)
	;{
		;
	;}
}

;------------------------
;Functions:
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

ReadMemory(MADDRESS, pid)
{
	VarSetCapacity(MVALUE,4,0)
	ProcessHandle := DllCall("OpenProcess", "Int", 24, "Char", 0, "UInt", pid, "UInt")
	DllCall("ReadProcessMemory", "UInt", ProcessHandle, "Ptr", MADDRESS, "Ptr", &MVALUE, "Uint",4)
	Loop 4
	result += *(&MVALUE + A_Index-1) << 8*(A_Index-1)
	Return, result
}

WriteProcessMemory(pid,address,wert)
{
	size=4 ;changeable
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