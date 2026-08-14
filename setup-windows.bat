@echo off
title Lakimboria WiFi Manager Setup
color 0A

echo =========================================
echo   Lakimboria WiFi Manager
echo   Powered by Mikhmon — Windows Setup
echo =========================================
echo.
echo  TIP: Download the GUI app from:
echo  https://github.com/Abdulnasserh/lakimboria-wifi/releases
echo  Double-click to start/stop the server easily.
echo =========================================
echo.

:: Save the current directory
set "BASEDIR=%~dp0"

:: Check if PHP is installed
where php >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [1] PHP not found. Downloading portable PHP...
    echo.
    if not exist "%BASEDIR%php" mkdir "%BASEDIR%php"
    pushd "%BASEDIR%php"
    
    :: Download PHP 8.3 portable ZIP
    echo   Downloading PHP 8.3 (Windows x64)...
    curl -L -o php.zip "https://downloads.php.net/~windows/releases/archives/php-8.3.12-nts-Win32-vs16-x64.zip"
    if exist php.zip (
        echo   Extracting...
        powershell -Command "Expand-Archive -Path php.zip -DestinationPath . -Force"
        del php.zip
        echo   PHP extracted successfully.
    ) else (
        echo   Download failed! Please install PHP manually from https://windows.php.net
        echo   Then re-run this script.
        popd
        pause
        exit /b 1
    )
    popd
)

:: Find PHP executable path
set PHP_PATH=
if exist "%BASEDIR%php\php.exe" set "PHP_PATH=%BASEDIR%php\php.exe"
if "%PHP_PATH%"=="" (
    where php >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        for /f "delims=" %%i in ('where php') do set "PHP_PATH=%%i"
    )
)

if "%PHP_PATH%"=="" (
    echo ERROR: Cannot find PHP executable.
    pause
    exit /b 1
)

echo [2] PHP found at: %PHP_PATH%
echo.

:: Check if Lakimboria files exist
if not exist "%BASEDIR%mikhmon\admin.php" (
    echo [3] Lakimboria not found. This script must be in the lakimboria-wifi folder.
    pause
    exit /b 1
)

echo [3] Starting Lakimboria server...
echo.

:: Start PHP built-in server (in a visible window so we can kill it by title)
start "Lakimboria Server" "%PHP_PATH%" -S 0.0.0.0:8081 -t "%BASEDIR%mikhmon"

:: Wait for server to start
timeout /t 2 /nobreak >nul

:: Auto-detect local IP address
set LOCAL_IP=
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    if not defined LOCAL_IP set "LOCAL_IP=%%a"
)
:: Trim leading space
for /f "tokens=* delims= " %%b in ("%LOCAL_IP%") do set "LOCAL_IP=%%b"

:: Open browser
echo [4] Opening Lakimboria dashboard...
start http://localhost:8081

echo.
echo =========================================
echo   Lakimboria WiFi Manager is running at:
echo   http://localhost:8081
echo.
echo   Login: mikhmon / 1234
echo.
echo   -----------------------------------------
echo   YOUR PC IP: %LOCAL_IP%
echo   -----------------------------------------
echo   On MikroTik, set Lakimboria URL to:
echo   http://%LOCAL_IP%:8081
echo   -----------------------------------------
echo.
echo   Press any key to STOP the server.
echo =========================================
echo.

:: Keep window open until user presses a key
pause

:: Kill the PHP server by window title (works because we used start with a title, no /B)
taskkill /fi "WINDOWTITLE eq Lakimboria Server" >nul 2>nul
:: Fallback: kill php.exe if the above didn't work
taskkill /im php.exe /f >nul 2>nul
echo   Server stopped.
