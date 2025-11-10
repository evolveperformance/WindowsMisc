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
findstr /V /I /C:"WSearch" /C:"AppReadiness" /C:"StartMenuExperienceHost.exe" /C:"TextInputHost.exe" /C:"ctfmon.exe" /C:"RuntimeBroker.exe" /C:"ClipSVC" /C:"InstallService" /C:"ApxSvc" /C:"LicenseManager" /C:"CDPSvc" /C:"CDPUserSvc" /C:"BITS" /C:"reg.exe add \"HKLM\%HIVE%\Services\WSearch\"" /C:"REN \"%DRIVE_LETTER%:\Windows\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\StartMenuExperienceHost.exe\"" /C:"REN \"%DRIVE_LETTER%:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\TextInputHost.exe\"" "%disableBat%" > "%tempBat%"

move /Y "%tempBat%" "%disableBat%" >nul

endlocal
pause
