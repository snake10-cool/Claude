@echo off
chcp 1252 >nul
setlocal

rem ================== EINSTELLUNGEN ==================
rem Tastenkuerzel (z.B. CTRL+ALT+W, CTRL+SHIFT+F1, ALT+F9):
set "HOTKEY=CTRL+ALT+W"
rem ===================================================

set "DIR=%APPDATA%\WortTipper"
if not exist "%DIR%" mkdir "%DIR%"

rem Eingabefelder fuer Wort und WPM anzeigen (vorausgefuellt mit den letzten Werten)
powershell -NoProfile -Command "Add-Type -AssemblyName Microsoft.VisualBasic; $f='%DIR%\wort.txt'; $a=@('Hallo Welt','500'); if(Test-Path $f){$a=@(Get-Content $f)+@('','')}; $w=[Microsoft.VisualBasic.Interaction]::InputBox('Welches Wort soll in Firefox getippt werden?','WortTipper',$a[0]); if(!$w){exit 1}; $p=[Microsoft.VisualBasic.Interaction]::InputBox('Geschwindigkeit in WPM:','WortTipper',$(if($a[1]){$a[1]}else{'500'})); if($p -notmatch '^[0-9]+$'){$p='500'}; Set-Content -LiteralPath $f -Value $w,$p -Encoding Default"
if errorlevel 1 (
  echo Abgebrochen.
  pause
  goto :eof
)

rem VBS-Skript (unten in dieser Datei) extrahieren
powershell -NoProfile -Command "$t=Get-Content -LiteralPath '%~f0'; $i=[array]::IndexOf($t,':VBS'); $t[($i+1)..($t.Count-1)] | Set-Content -LiteralPath '%DIR%\tippen.vbs' -Encoding Default"

rem Verknuepfung mit Tastenkuerzel im Startmenue anlegen
powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Programs')+'\WortTipper.lnk'); $s.TargetPath='wscript.exe'; $s.Arguments='\"%DIR%\tippen.vbs\"'; $s.Hotkey='%HOTKEY%'; $s.Save()"

echo.
echo Fertig! Druecke in Firefox %HOTKEY%, um dein Wort ins aktive Eingabefeld zu tippen.
echo Wort aendern: diese .bat einfach nochmal starten.
echo Entfernen: Startmenue-Verknuepfung "WortTipper" und Ordner %DIR% loeschen.
pause
goto :eof

:VBS
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.OpenTextFile(fso.GetParentFolderName(WScript.ScriptFullName) & "\wort.txt")
w = f.ReadLine
wpm = 500
If Not f.AtEndOfStream Then wpm = CDbl(Trim(f.ReadLine))
f.Close
If wpm <= 0 Then wpm = 500
' Sekunden pro Zeichen: 1 Wort = 5 Zeichen
spc = 60 / (wpm * 5)
' warten, bis die Kuerzel-Tasten losgelassen sind
WScript.Sleep 400
If sh.AppActivate("Mozilla Firefox") Then
  WScript.Sleep 150
  t0 = Timer
  For i = 1 To Len(w)
    c = Mid(w, i, 1)
    If InStr("+^%~(){}[]", c) > 0 Then c = "{" & c & "}"
    sh.SendKeys c
    ' auf festen Zeitplan warten, damit der Schnitt genau stimmt
    ziel = t0 + i * spc
    Do While Timer < ziel And Timer >= t0
      WScript.Sleep 1
    Loop
  Next
End If
