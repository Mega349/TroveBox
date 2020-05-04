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
global ScriptVersion := "0.1.0"
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

;;CD = Camera Distance
global CDSize := 0
global CDBase := "0x00000000"
global minCDOffsetString := "0x0+0x0"
global maxCDOffsetString := "0x0+0x0"

global PlayernameSize := 0
global PlayernameBase := "0x00000000"
global PlayernameOffsetString := "0x0+0x0"

global cViewSize := 0
global cViewBase := "0x00000000"
global cViewHightSOffsetString := "0x0+0x0"
global cViewWidthOffsetString := "0x0+0x0"

global accountIdSize := 0
global accountIdbase := "0x00000000"
global accountIdOffsetString := "0x0+0x0+0x0+0x0+0x0+0x0"

;Pattern for Pattern Scan
;;"????????ngle block out of existence" -> AccountID [8] + ZeroByte + String in Trove Language Var : $prefabs_abilities_delete_block_metaforge_item_description in prefabs_abilities.binfab
mainIdPattern := ["?", "?", "?", "?", "?", "?", "?", "?", "?", 0x6E, 0x67, 0x6C, 0x65, 0x20, 0x62, 0x6C, 0x6F, 0x63, 0x6B, 0x20, 0x6F, 0x75, 0x74, 0x20, 0x6F, 0x66, 0x20, 0x65, 0x78, 0x69, 0x73, 0x74, 0x65, 0x6E, 0x63, 0x65]

;default Config
PointerAutoUpdate := 1 ;true/false
EnableUpdateCheck := 1 ;true/false
ShowTooltip := 1 ;true/false
posDisTrigger := 0.5 ;in Blocks
moveTolerance := 2 ;in Blocks
upSpeed := 10 ;Trove Accel. (10 is like Normal Jump)
jumpDelay := 2 ;in Sec
inviteJumpDelay := 1 ;in Sec
joinMainDistanceStanding := 1 ;in Blocks
joinMainDistanceMoving := 10 ;in Blocks

;default Keys
;;...

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
global accountIdAddress := []

mainIdAddress := []

global JUMPTIME := []
global STUCKTIMEOUT := []

inviteJumpTime := []
teleportCooldown := []

PIDArr := []
IDArr := []
playernameArr := []
AccountIdArr := []

positionArr := []
currentMainPos := []
currentAltPos := [] ;just for the current account for position checks
oldPosMain := []
moveDone := []
accIsMoving := []
joinRequest := [] ;0 = None | 1 = Stop Moving | 2 = Need Teleport (wait for Cooldown) | 3 = Need validation
positionSyncDelay := []
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
Gosub, main
;Gosub, readTroveWindows
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
#Include, classMemory.ahk
