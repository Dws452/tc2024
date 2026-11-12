@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0auto.ps1" %*
pause
