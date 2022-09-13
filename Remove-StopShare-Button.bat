@echo off
setlocal enabledelayedexpansion

set VERSION=1.0
set "REMOTE_CORE=https://raw.githubusercontent.com/agamsol/Chrome-Remote-Desktop-Remove-Stop-Share-Button/!VERSION!/remoting_core.dll"

:: CHECK EVALATIONS
>nul 2>&1 net session || (
    echo:
    echo ERROR: Please run this script as administrator
    >nul timeout /t 5
    exit /b 1
)


for %%a in ("!ProgramFiles(x86)!" "!ProgramFiles!") do (
    if exist "%%~a\Google\Chrome Remote Desktop" (
        if exist "%%~a\Google\Chrome Remote Desktop\CurrentVersion" (
            call :CHROME_REMOTE_DESKTOP_INSTALLED "%%~a\Google\Chrome Remote Desktop\CurrentVersion"
        ) else (
            for /f "delims=" %%b in ('dir /b "%%~a\Google\Chrome Remote Desktop\*"') do (
                call :CHROME_REMOTE_DESKTOP_INSTALLED "%%~a\Google\Chrome Remote Desktop\%%~b"
            )
        )
        echo Process has been finished
        pause
        exit /b 0
    )
)
echo:
echo ERROR: Chrome remote desktop is not installed
>nul timeout /t 5
exit /b 1

:CHROME_REMOTE_DESKTOP_INSTALLED [PATH]
set "CRD_PATH=%~1"
set PROCESSES_ENDED=0

for /f "delims=" %%a in ('dir /b "!CRD_PATH!\*.exe"') do >nul 2>&1 taskkill /f /im "%%a" && set /a PROCESSES_ENDED+=1
echo:
echo     [+] INFO: Successfully killed !PROCESSES_ENDED! process(es)

del /q "!CRD_PATH!\remoting_core.dll" && (
    echo:
    echo     [+] INFO: Successfully deleted remote_core.dll
)

curl -sLko "!CRD_PATH!\remoting_core.dll" "!REMOTE_CORE!" && (
    echo:
    echo     [+] INFO: Successfully downloaded the new remoting-core
)

if exist "!CRD_PATH!\remoting_host.exe" (
    "!CRD_PATH!\remoting_host.exe"
    echo:
    echo     [+] INFO: Successfully launched chrome-remote-desktop.
)

echo:
echo     [+] INFO: You may now connect and you should'nt notice a Stop-Share button
echo:
echo     [*] Press any key to EXIT the script
pause >nul
exit /b 0