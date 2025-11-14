@echo off
setlocal enabledelayedexpansion

REM Go to build folder
cd /d "C:\Windows\Evolve\Utilities\Service Builder\build"

REM Find the only build folder
set "buildDir="
for /f "delims=" %%D in ('dir /b /ad') do (
    set "buildDir=%%D"
    goto :found
)
:found

if not defined buildDir (
    echo No build folder found!
    pause
    exit /b 1
)

REM Core file path (plural "Services-")
set "disableBat=%buildDir%\Services-Disable.bat"

if not exist "%disableBat%" (
    echo Services-Disable.bat not found in %buildDir%!
    pause
    exit /b 1
)

set "tempBat=%disableBat%.tmp"

REM REMOVE lines containing dangerous disables/renames (delete in output)
findstr /V /I /C:"AppReadiness" /C:"RuntimeBroker.exe" /C:"ClipSVC" /C:"ApxSvc" /C:"RpcSS" /C:"DcomLaunch" /C:"EventLog" /C:"BFE" "%disableBat%" > "%tempBat%"
:: /C:"Wcmsvc"
move /Y "%tempBat%" "%disableBat%" >nul

endlocal
pause

