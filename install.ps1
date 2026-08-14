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

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0")

$zipUrl = "$repo/archive/refs/heads/main.zip"
$zipPath = "$env:TEMP\lakimboria.zip"
$wc.DownloadFile($zipUrl, $zipPath)
Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
Move-Item "$env:TEMP\lakimboria-wifi-main" $dir -Force
Remove-Item $zipPath -Force
Write-Host "  Files extracted to $dir" -ForegroundColor Green

# --- 2. Download Portable PHP ---
Write-Host "[2/4] Downloading and setting up PHP..." -ForegroundColor Yellow
$phpUrl = "https://downloads.php.net/~windows/releases/archives/php-8.3.12-nts-Win32-vs16-x64.zip"
$phpZip = "$env:TEMP\php.zip"
$phpDir = "$dir\php"
$wc.DownloadFile($phpUrl, $phpZip)
New-Item -ItemType Directory -Path $phpDir -Force | Out-Null
Expand-Archive -Path $phpZip -DestinationPath $phpDir -Force
Remove-Item $phpZip -Force
Write-Host "  Portable PHP extracted inside the project directory." -ForegroundColor Green

# --- 3. Compile the Desktop App Launcher (.exe) ---
Write-Host "[3/4] Compiling the Lakimboria Manager App (.exe)..." -ForegroundColor Yellow
try {
    # Set TLS 1.2, set NuGet, and trust PSGallery to prevent any interactive prompt hangs
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    Write-Host "  Checking secure package manager (NuGet)..." -ForegroundColor DarkGray
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue
    
    Write-Host "  Configuring trusted repository (PSGallery)..." -ForegroundColor DarkGray
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue

    # Install ps2exe if not available
    if (-not (Get-Module -ListAvailable -Name ps2exe)) {
        Write-Host "  Installing PS2EXE compiler module (takes 1-2 minutes depending on your speed)..." -ForegroundColor DarkGray
        Install-Module -Name ps2exe -Force -Scope CurrentUser -AllowClobber -Confirm:$false
    }
    
    # Run the compilation
    Write-Host "  Compiling script to standalone .exe..." -ForegroundColor DarkGray
    ps2exe -inputFile "$dir\manager\lakimboria-manager.ps1" `
           -outputFile "$dir\LakimboriaWiFiManager.exe" `
           -iconFile "$dir\manager\icon.ico" `
           -title "Lakimboria WiFi Manager" `
           -description "Lakimboria WiFi Manager — MikroTik Hotspot Launcher" `
           -company "Deeplearn Technologies" `
           -product "Lakimboria WiFi Manager" `
           -version "1.0.0.0"
           
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

# --- 5. Auto-detect PC IP and generate ready-to-paste MikroTik command ---
Write-Host "[5/5] Detecting your PC's local IP address..." -ForegroundColor Yellow

# Get the best local IPv4 address (prefer 192.168.x.x or 10.x.x.x, skip loopback/APIPA)
$localIP = $null
try {
    # Method 1: Get IP by checking route to an external address (most reliable)
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.254.*" -and 
        $_.PrefixOrigin -ne "WellKnown"
    } | Sort-Object -Property { 
        if ($_.IPAddress -like "192.168.*") { 0 } 
        elseif ($_.IPAddress -like "10.*") { 1 } 
        else { 2 } 
    } | Select-Object -First 1).IPAddress
} catch {}

if (-not $localIP) {
    # Fallback: parse ipconfig
    $localIP = (ipconfig | Select-String "IPv4" | Select-Object -First 1).ToString().Split(":")[-1].Trim()
}

if ($localIP) {
    Write-Host "  Detected IP: $localIP" -ForegroundColor Green
    
    # Update install.rsc with the correct IP
    $rscPath = "$dir\install.rsc"
    if (Test-Path $rscPath) {
        $rscContent = Get-Content $rscPath -Raw
        $rscContent = $rscContent -replace 'LAKIMBORIAURL "http://[^"]*"', "LAKIMBORIAURL `"http://${localIP}:8081`""
        Set-Content -Path $rscPath -Value $rscContent -NoNewline
        Write-Host "  Updated install.rsc with your IP ($localIP)" -ForegroundColor Green
    }
} else {
    $localIP = "YOUR_PC_IP"
    Write-Host "  Could not auto-detect IP. You'll need to edit install.rsc manually." -ForegroundColor Red
}

# Generate the one-liner MikroTik command
$mikroTikCmd = "/tool fetch url=`"https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.rsc`" dst-path=install.rsc; /import install.rsc"

# Also generate a local version with correct IP that can be pasted directly
$localRscCmd = @"
:local GITHUB "https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main"
:local SERVERNAME "hotspot"
:local LAKIMBORIAURL "http://${localIP}:8081"
"@

# Save a ready-to-paste command file on Desktop
$cmdFile = "$desktop\MikroTik-Paste-This.txt"
$cmdFileContent = @"
============================================
  PASTE THIS INTO YOUR MIKROTIK TERMINAL
  (WinBox > New Terminal, or SSH)
============================================

OPTION A: One-line auto-install (fetches from GitHub):
------------------------------------------------------
/tool fetch url="https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.rsc" dst-path=install.rsc; /import install.rsc

NOTE: After running Option A, you must update the URL in the router:
/file set "hotspot/conf.js" contents="var config = {\r\n  loginvc : \"Weka Kodi ya Vocha kisha bonyeza Unganisha.\",\r\n  loginup : \"Weka Jina la Mtumiaji na Nywila kisha bonyeza Unganisha.\",\r\n  voucherCode : \"Kodi ya Vocha\",\r\n  setCase : \"none\",\r\n  defaultMode : \"voucher\",\r\n  theme : \"default\",\r\n  url : \"http://${localIP}:8081\",\r\n  SessionName : \"hotspot\",\r\n}\r\n"


OPTION B: Use the local install.rsc file (already has your IP):
---------------------------------------------------------------
1. Open WinBox > Files
2. Drag & drop the file: $dir\install.rsc
3. Then in Terminal run: /import install.rsc


Your PC IP: $localIP
Server will run at: http://${localIP}:8081
============================================
"@
Set-Content -Path $cmdFile -Value $cmdFileContent
Write-Host "  Saved MikroTik command to: $cmdFile" -ForegroundColor Green

# --- Done ---
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTALLATION COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Folder: $dir" -ForegroundColor Gray
Write-Host "  Your PC IP: $localIP" -ForegroundColor White
Write-Host ""
Write-Host "  WHAT TO DO NEXT:" -ForegroundColor White
Write-Host "  1. Double-click 'Lakimboria WiFi Manager' on your Desktop to start the server." -ForegroundColor White
Write-Host "  2. Open 'MikroTik-Paste-This.txt' on your Desktop." -ForegroundColor White
Write-Host "  3. Copy the command and paste it into MikroTik Terminal (WinBox)." -ForegroundColor White
Write-Host "  4. Done! Your hotspot is ready." -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
