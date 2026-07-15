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

:: Check if PHP is installed
where php >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [1] PHP not found. Downloading portable PHP...
    echo.
    if not exist "php" mkdir php
    cd php
    
    :: Download PHP 8.3 portable ZIP
    echo   Downloading PHP 8.3 (Windows x64)...
    curl -L -o php.zip "https://windows.php.net/downloads/releases/php-8.3.12-nts-Win32-vs16-x64.zip"
    if exist php.zip (
        echo   Extracting...
        powershell -Command "Expand-Archive -Path php.zip -DestinationPath . -Force"
        del php.zip
        echo   PHP extracted successfully.
    ) else (
        echo   Download failed! Please install PHP manually from https://windows.php.net
        echo   Then re-run this script.
        pause
        exit /b 1
    )
    cd ..
)

:: Find PHP executable path
set PHP_PATH=
if exist "php\php.exe" set PHP_PATH=php\php.exe
if "%PHP_PATH%"=="" (
    where php >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        for /f "delims=" %%i in ('where php') do set PHP_PATH=%%i
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
if not exist "mikhmon\admin.php" (
    echo [3] Lakimboria not found. This script must be in the mikhmon-tz folder.
    pause
    exit /b 1
)

echo [3] Starting Lakimboria server...
echo.

:: Start PHP built-in server
start "Lakimboria Server" /B "%PHP_PATH%" -S 0.0.0.0:8080 -t "mikhmon"

:: Wait for server to start
timeout /t 2 /nobreak >nul

:: Open browser
echo [4] Opening Lakimboria dashboard...
start http://localhost:8080

echo.
echo =========================================
echo   Lakimboria WiFi Manager is running at:
echo   http://localhost:8080
echo.
echo   Login: mikhmon / 1234
echo.
echo   Close this window to stop the server.
echo =========================================
echo.

:: Keep window open
pause
taskkill /fi "WINDOWTITLE eq Lakimboria Server" >nul 2>nul
