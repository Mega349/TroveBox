#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Input
#SingleInstance force
#WinActivateForce
;SetBatchLines -1
SetTitleMatchMode, 3
OnExit("ExitFunktion")

;------------------------
;Variable:
;------------------------

;File / Name / Location Vars
global ScriptName := "TroveBox"
global ScriptVersion := "1.0.0"
TempPointerFile = %A_Temp%\Trove_Pointer.ini
TempVersionsFile = %A_Temp%\Versions.ini
PointerHostFile := "https://webtrash.lima-city.de/Trove_Pointer_Host.ini"
VersionsFile := "https://webtrash.lima-city.de/Versions.ini"
PointerFile := "pointer.ini"
iniFile := "TroveBox.ini"

;Pointer blank Pattern
global LastUpdateSupport := "01.01.2000"

global SkipSize := 0
global SkipBase := "0x00000000"
global xSkipOffsetString := "0x0+0x0+0x0+0x0+0x0"
global ySkipOffsetString := "0x0+0x0+0x0+0x0+0x0"
global zSkipOffsetString := "0x0+0x0+0x0+0x0+0x0"

global AccelerationSize := 0
global AccelerationBase := "0x00000000"
global xAccelerationOffsetString := "0x0+0x0+0x0+0x0+0x0"
global yAccelerationOffsetString := "0x0+0x0+0x0+0x0+0x0"
global zAccelerationOffsetString := "0x0+0x0+0x0+0x0+0x0"

global ViewSize := 0
global ViewBase := "0x00000000"
global xViewOffsetString := "0x0+0x0+0x0+0x0+0x0"
global yViewOffsetString := "0x0+0x0+0x0+0x0+0x0"
global zViewOffsetString := "0x0+0x0+0x0+0x0+0x0"

global SpeedSize := 0
global SpeedBase := "0x00000000"
global SpeedOffsetString := "0x0+0x0+0x0+0x0+0x0"

;CD = Camera Distance
global CDSize := 0
global CDBase := "0x00000000"
global minCDOffsetString := "0x0+0x0"
global maxCDOffsetString := "0x0+0x0"

global PlayernameSize := 0
global PlayernameBase := "0x00000000"
global PlayernameOffsetString := "0x0+0x0"

global cViewSize := 0
global cViewBase := "0x00000000"
global cViewHightString := "0x0+0x0"
global cViewWidthString := "0x0+0x0"

;default Config
PointerAutoUpdate := 1
EnableUpdateCheck := 1
ShowTooltip := 1

;default Keys

;Internal Vars
global xSkipAddress := []
global ySkipAddress := []
global zSkipAddress := []
global xAccelerationAddress := []
global yAccelerationAddress := []
global zAccelerationAddress := []
global xViewAddress := []
global yViewAddress := []
global zViewAddress := []
global SpeedAddress := []
global currentCDAdress := []
global minCDAdress := []
global maxCDAdress := []
global PlayernameAddress := []
global cViewHightAddress := []
global cViewWidthAddress := []
PIDArr := []
playernameArr := []
IDArr := []
positionArr := []
currentPosMain := []
oldPosMain := []
moveDone := []
accIsMoving := []
posDisTrigger := 1
splitDelimiter := "#"

;------------------------
;Start:
;------------------------

SplashTextOn,130,25,% ScriptName " v" ScriptVersion,% "Starting..."

;------------------------
;Admin Check:
;------------------------

if !A_IsAdmin
{
	try
	{
		Run *RunAs %A_ScriptFullPath%
		ExitApp
	}
	ExitApp ;continue without Admin permissions? - here no
}

;------------------------
;Create and Read INI File:
;------------------------

Gosub, loadINI

;------------------------
;Auto Update:
;------------------------

if (PointerAutoUpdate == TRUE)
{
	try
	{
		UrlDownloadToFile, %PointerHostFile% , %TempPointerFile%
	}
	if FileExist(TempPointerFile)
	{
		ReadPointerfromini(TempPointerFile)
		if (WritePointertoini(PointerFile) != TRUE)
		{
			ReadPointerfromini(PointerFile)
		}
	    FileDelete,%TempPointerFile%
	}
}

;------------------------
;Update check:
;------------------------

if (EnableUpdateCheck == TRUE)
{
	SplashTextOn,200,25,% ScriptName " v" ScriptVersion,% "Check for Update..."
	try
	{
		UrlDownloadToFile, %VersionsFile%, %TempVersionsFile%
	}
	if FileExist(TempVersionsFile)
	{
		IniRead,NewScriptVersion,%TempVersionsFile%,Version,TB
		if (NewScriptVersion != "ERROR" && NewScriptVersion != ScriptVersion)
		{
			SplashTextOff
			MsgBox, 4, %ScriptName%,% "An Update is available! " ScriptVersion " -> " NewScriptVersion "`nDownload now?"
			IfMsgBox, Yes
			{
				IniRead,NewScriptVersionURL,%TempVersionsFile%,URL,TB
				run, %NewScriptVersionURL%
			}
		}
	}
	FileDelete,%TempVersionsFile%
}

;------------------------
;GUI:
;------------------------

SplashTextOn,200,25,% ScriptName " v" ScriptVersion,% "Building GUI..."
Gosub, GUI
SplashTextOff

;------------------------
;End Startup:
;------------------------

SetTimer, ToolTip, 70
Gosub, InitHotkeys
;Gosub, main
return

;------------------------
;funktions/hotkeys/subroutine:
;------------------------

#Include, inifile.ahk
#Include, GUI.ahk
#Include, hotkeys.ahk
#Include, subroutine.ahk
#Include, main.ahk
#Include, funktions.ahk
