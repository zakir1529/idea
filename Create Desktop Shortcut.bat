@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$sh=New-Object -ComObject WScript.Shell;$desktop=[Environment]::GetFolderPath('Desktop');$s=$sh.CreateShortcut(\"$desktop\ZYRO Retail POS.lnk\");$t=(Resolve-Path 'dist-lightweight\ZYRO-Retail-POS\ZYRO.exe' -ErrorAction SilentlyContinue);if(-not $t){$t=(Resolve-Path 'ZYRO.exe' -ErrorAction SilentlyContinue)};if(-not $t){$t=(Resolve-Path 'Launch ZYRO.bat')};$s.TargetPath=$t.Path;$s.WorkingDirectory=[System.IO.Path]::GetDirectoryName($t.Path);$ico=(Resolve-Path 'ZYRO.ico' -ErrorAction SilentlyContinue);if($ico){$s.IconLocation=$ico.Path};$s.Save();Write-Host 'Desktop shortcut created successfully on your desktop!'"
pause
