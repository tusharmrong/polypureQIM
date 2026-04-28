@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0new-release.ps1" -Bump patch
pause
