#include <Array.au3>
#include <File.au3>
#include <Date.au3>
#include <GuiListBox.au3>
#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <AutoItConstants.au3>
#include <FontConstants.au3>
#include <MsgBoxConstants.au3>

HotKeySet("{F11}","LoginMeme");

While 1
   Sleep(1000);
WEnd

Func LoginMeme()
   Local $aAccounts = LoadAccounts(False);
   Local Static $LastResetTime=0;
   Local Static $HitCounter=0;
   Local Static $AccountIndex=0;
   ;MsgBox(0,"hi!","hihi");;
   If((_GetUnixTime() - $LastResetTime) > 1) Then
	  $HitCounter=0;
	  $LastResetTime=_GetUnixTime();
   EndIf
   $HitCounter+=1;
   If($HitCounter >= 3) Then
	  $aAccounts = LoadAccounts(True);
	  Local $GUI = GUICreate("Select account", 300, 300) ;create gui
	  Local $ListBox = _GUICtrlListBox_Create($GUI, "", 0, 0,300,300) ;create listbox
	  For $i = 0 To (UBound($aAccounts,1) -1)
		 ;ConsoleWrite("adding: " & $i & ":" & $aAccounts[$i][2]);
		 ;MsgBox(0, $i, $FileList[$i])
		 _GUICtrlListBox_AddString($ListBox,$i & ": " & ($aAccounts[$i])[0]);
	  Next
	  GUISetState() ;show the gui
	  WinSetOnTop($GUI,"",$WINDOWS_ONTOP);
	  Local $selected=-1
	  Do
		 Sleep(100);
		 $selected=_GUICtrlListBox_GetCurSel ( $ListBox );
	  Until $selected <> -1;
	  $AccountIndex=$selected;
	  ;ConsoleWriteError(@CRLF & "index: " &$AccountIndex & @CRLF  );
	  GUIDelete() ; if autoit expect me to clean up all inner gui controls myself, and this technically leaks memory, here is a list of all the f*ks i give:
   EndIf
   Send((($aAccounts[$AccountIndex])[1]) & "{TAB}" & (($aAccounts[$AccountIndex])[2]));
EndFunc

Func LoadAccounts( $bForceResetCache = False )
   Local Static $cache=[];
   ;ConsoleWrite("cache size: " & UBound($cache[0]) & @CrLf);
   if( Not $bForceResetCache And UBound($cache[0]) == 3) Then
	 ;ConsoleWrite("loaded from cache!");
	  return $cache
   EndIf
   ReDim $cache[0];
   Local $read=[];
   _FileReadToArray("accounts.txt",$read,$FRTA_NOCOUNT + $FRTA_INTARRAYS + $FRTA_ENTIRESPLIT ,":::")
   For $i=0 To (UBound($read)-1) Step 1
	  If( (Not IsArray($read[$i])) Or (UBound($read[$i]) <> 3) Or ( StringLeft((($read[$i])[0]),1) == "#" ) ) Then
		 ;_ArrayDisplay($read[$i],"skipping");
	  Else
		 ;_ArrayDisplay($read[$i],"adding");
		 _ArrayAdd($cache,$read[$i],0,Default,Default,$ARRAYFILL_FORCE_SINGLEITEM );
	  EndIf
   Next
   ;_ArrayDisplay($cache,"reloaded cache.");
   return $cache;
EndFunc

Func _GetUnixTime($sDate = 0);Date Format: 2013/01/01 00:00:00 ~ Year/Mo/Da Hr:Mi:Se

    Local $aSysTimeInfo = _Date_Time_GetTimeZoneInformation()
    Local $utcTime = ""

    If Not $sDate Then $sDate = _NowCalc()

    If Int(StringLeft($sDate, 4)) < 1970 Then Return ""

    If $aSysTimeInfo[0] = 2 Then ; if daylight saving time is active
        $utcTime = _DateAdd('n', $aSysTimeInfo[1] + $aSysTimeInfo[7], $sDate) ; account for time zone and daylight saving time
    Else
        $utcTime = _DateAdd('n', $aSysTimeInfo[1], $sDate) ; account for time zone
    EndIf

    Return _DateDiff('s', "1970/01/01 00:00:00", $utcTime)
EndFunc   ;==>_GetUnixTime
