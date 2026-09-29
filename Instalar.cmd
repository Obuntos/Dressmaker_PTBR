@echo off
setlocal
cd /d "%~dp0"
if not exist "%~dp0sistema\Instalador.ps1" (
    echo O instalador esta incompleto. Extraia o ZIP inteiro antes de abrir.
    pause
    exit /b 1
)
start "" powershell.exe -NoProfile -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0sistema\Instalador.ps1"
endlocal
