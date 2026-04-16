@echo off
REM WSL2 port forwarding for homeDX backend (port 4000). Run as Administrator.
REM pushd gives CMD a drive letter when the repo is opened via \\wsl.localhost\... (UNC);
REM otherwise "UNC paths are not supported" and cwd becomes C:\Windows\System32.
setlocal
pushd "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%CD%\setup-wsl-port-forward.ps1"
set ERR=%ERRORLEVEL%
popd
exit /b %ERR%
