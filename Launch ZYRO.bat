@echo off
setlocal
cd /d "%~dp0"

if exist "ZYRO.exe" (
    start "" "ZYRO.exe"
    exit /b
)

if exist "dist-lightweight\ZYRO-Retail-POS\ZYRO.exe" (
    start "" "dist-lightweight\ZYRO-Retail-POS\ZYRO.exe"
    exit /b
)

if exist "Start ZYRO.vbs" (
    start "" wscript.exe "Start ZYRO.vbs"
    exit /b
)

echo [ERROR] ZYRO executable could not be found.
pause
