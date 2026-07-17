# Lakimboria WiFi Manager — All-in-One Installer (Windows)
# Run in PowerShell as Administrator:
#   irm https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$repo = "https://github.com/Abdulnasserh/lakimboria-wifi"
$dir = "$env:USERPROFILE\lakimboria-wifi"
$desktop = [Environment]::GetFolderPath("Desktop")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Lakimboria WiFi Manager Installer" -ForegroundColor Cyan
Write-Host "  Deeplearn Technologies — Tanzania" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. Download and Extract Repository ---
Write-Host "[1/4] Downloading Lakimboria files..." -ForegroundColor Yellow

# Kill any locked running processes first to prevent directory deletion errors
Stop-Process -Name "php" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "LakimboriaWiFiManager" -Force -ErrorAction SilentlyContinue

if (Test-Path $dir) {
    Write-Host "  Existing folder found. Cleaning up for fresh install..." -ForegroundColor DarkGray
    Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
}

$zipUrl = "$repo/archive/refs/heads/main.zip"
$zipPath = "$env:TEMP\lakimboria.zip"
(New-Object System.Net.WebClient).DownloadFile($zipUrl, $zipPath)
Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
Move-Item "$env:TEMP\lakimboria-wifi-main" $dir -Force
Remove-Item $zipPath -Force
Write-Host "  Files extracted to $dir" -ForegroundColor Green

# --- 2. Download Portable PHP ---
Write-Host "[2/4] Downloading and setting up PHP..." -ForegroundColor Yellow
$phpUrl = "https://downloads.php.net/~windows/releases/archives/php-8.3.12-nts-Win32-vs16-x64.zip"
$phpZip = "$env:TEMP\php.zip"
$phpDir = "$dir\php"
(New-Object System.Net.WebClient).DownloadFile($phpUrl, $phpZip)
New-Item -ItemType Directory -Path $phpDir -Force | Out-Null
Expand-Archive -Path $phpZip -DestinationPath $phpDir -Force
Remove-Item $phpZip -Force
Write-Host "  Portable PHP extracted inside the project directory." -ForegroundColor Green

# --- 3. Compile the Desktop App Launcher (.exe) ---
Write-Host "[3/4] Compiling the Lakimboria Manager App (.exe)..." -ForegroundColor Yellow
try {
    # Set TLS 1.2, set NuGet, and trust PSGallery to prevent any interactive prompt hangs
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue | Out-Null

    # Install ps2exe if not available
    if (-not (Get-Module -ListAvailable -Name ps2exe)) {
        Write-Host "  Installing PS2EXE compiler module (takes a moment)..." -ForegroundColor DarkGray
        Install-Module -Name ps2exe -Force -Scope CurrentUser -AllowClobber -Confirm:$false | Out-Null
    }
    
    # Run the compilation
    ps2exe -inputFile "$dir\manager\lakimboria-manager.ps1" `
           -outputFile "$dir\LakimboriaWiFiManager.exe" `
           -iconFile "$dir\manager\icon.ico" `
           -title "Lakimboria WiFi Manager" `
           -description "Lakimboria WiFi Manager — MikroTik Hotspot Launcher" `
           -company "Deeplearn Technologies" `
           -product "Lakimboria WiFi Manager" `
           -version "1.0.0.0" | Out-Null
           
    Write-Host "  Successfully compiled LakimboriaWiFiManager.exe!" -ForegroundColor Green
} catch {
    Write-Host "  Compilation warning: $_" -ForegroundColor Red
    Write-Host "  Falling back: Creating a double-clickable .bat launcher..." -ForegroundColor DarkGray
    
    # Create fallback .bat file which runs powershell silently in the background
    $batContent = "@echo off`r`nstart /B powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"%~dp0manager\lakimboria-manager.ps1`""
    $batContent | Out-File "$dir\LakimboriaWiFiManager.bat" -Encoding ASCII
}

# --- 4. Create Desktop Shortcut ---
Write-Host "[4/4] Creating Desktop Shortcut..." -ForegroundColor Yellow
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut("$desktop\Lakimboria WiFi Manager.lnk")

if (Test-Path "$dir\LakimboriaWiFiManager.exe") {
    $shortcut.TargetPath = "$dir\LakimboriaWiFiManager.exe"
    $shortcut.WorkingDirectory = $dir
} else {
    # If compilation failed, point to the fallback .bat file
    $shortcut.TargetPath = "$dir\LakimboriaWiFiManager.bat"
    $shortcut.WorkingDirectory = $dir
}

$shortcut.Description = "Launch Lakimboria WiFi Manager Dashboard"
$shortcut.IconLocation = "$dir\manager\icon.ico"
$shortcut.Save()
Write-Host "  Desktop Shortcut created: 'Lakimboria WiFi Manager'" -ForegroundColor Green

# --- Done ---
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTALLATION COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Folder: $dir" -ForegroundColor Gray
Write-Host ""
Write-Host "  WHAT TO DO NEXT:"
Write-Host "  1. Double-click the 'Lakimboria WiFi Manager' icon on your Desktop!"
Write-Host "  2. It will automatically start the server and open your browser."
Write-Host "  3. Paste the install.rsc command into your MikroTik terminal."
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
