@echo off
setlocal
cd /d %~dp0
:MAIN
cls
echo Your choice:
echo 1) Run disable Feature Update
echo 2) Run enable Feature Update
echo 3) Exit
CHOICE /N /C:123 /M "Enter your choice here:"%1	
IF ERRORLEVEL ==3 GOTO EXIT
IF ERRORLEVEL ==2 GOTO ENABLEFU
IF ERRORLEVEL ==1 GOTO DISABLEFU
:DISABLEFU
echo[
powershell -ExecutionPolicy Bypass -File "DisableFU.ps1"
pause
goto MAIN
:ENABLEFU
echo[
powershell -ExecutionPolicy Bypass -File "EnableFU.ps1"
pause
goto MAIN
:EXIT
exit