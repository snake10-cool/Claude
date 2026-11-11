@echo off
chcp 1252 >nul
setlocal

rem ================== EINSTELLUNGEN ==================
rem Das Wort/der Text, der getippt werden soll:
set "WORT=Hallo Welt"
rem Tastenkuerzel (z.B. CTRL+ALT+W, CTRL+SHIFT+F1, ALT+F9):
set "HOTKEY=CTRL+ALT+W"
rem ===================================================

set "DIR=%APPDATA%\WortTipper"
if not exist "%DIR%" mkdir "%DIR%"

rem Wort speichern (kann spaeter auch direkt in wort.txt geaendert werden)
>"%DIR%\wort.txt" echo(%WORT%

rem VBS-Skript (unten in dieser Datei) extrahieren
powershell -NoProfile -Command "$t=Get-Content -LiteralPath '%~f0'; $i=[array]::IndexOf($t,':VBS'); $t[($i+1)..($t.Count-1)] | Set-Content -LiteralPath '%DIR%\tippen.vbs' -Encoding Default"

rem Verknuepfung mit Tastenkuerzel im Startmenue anlegen
powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Programs')+'\WortTipper.lnk'); $s.TargetPath='wscript.exe'; $s.Arguments='\"%DIR%\tippen.vbs\"'; $s.Hotkey='%HOTKEY%'; $s.Save()"

echo.
echo Fertig! Druecke %HOTKEY%, um "%WORT%" in Firefox zu tippen.
echo Wort aendern: diese .bat anpassen und neu starten (oder %DIR%\wort.txt bearbeiten).
echo Entfernen: Startmenue-Verknuepfung "WortTipper" und Ordner %DIR% loeschen.
pause
goto :eof

:VBS
Set sh = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
p = fso.GetParentFolderName(WScript.ScriptFullName) & "\wort.txt"
w = fso.OpenTextFile(p).ReadLine
' warten, bis die Kuerzel-Tasten losgelassen sind
WScript.Sleep 400
If sh.AppActivate("Mozilla Firefox") Then
  WScript.Sleep 150
  out = ""
  For i = 1 To Len(w)
    c = Mid(w, i, 1)
    If InStr("+^%~(){}[]", c) > 0 Then c = "{" & c & "}"
    out = out & c
  Next
  sh.SendKeys out
End If
