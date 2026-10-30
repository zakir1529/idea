Option Explicit

Dim shell, files, folder, server, exePath
Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")

folder = files.GetParentFolderName(WScript.ScriptFullName)

' 1. Check if native standalone ZYRO.exe exists
exePath = files.BuildPath(folder, "ZYRO.exe")
If files.FileExists(exePath) Then
    shell.Run Chr(34) & exePath & Chr(34), 1, False
    WScript.Quit 0
End If

exePath = files.BuildPath(folder, "dist-lightweight\ZYRO-Retail-POS\ZYRO.exe")
If files.FileExists(exePath) Then
    shell.Run Chr(34) & exePath & Chr(34), 1, False
    WScript.Quit 0
End If

server = files.BuildPath(folder, "zyro-server.ps1")

If Not files.FileExists(server) Then
    MsgBox "ZYRO server file is missing.", vbCritical, "ZYRO"
    WScript.Quit 1
End If

' 2. Fallback: Start local server with ExecutionPolicy Bypass
shell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " & Chr(34) & server & Chr(34), 0, False
WScript.Sleep 1500
shell.Run "http://127.0.0.1:8765/", 1, False
