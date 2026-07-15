# Lakimboria WiFi Manager — One-Command Installer (Windows)
# Run in PowerShell as Administrator:
#   irm https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$repo = "https://github.com/Abdulnasserh/lakimboria-wifi"
$dir = "$env:USERPROFILE\lakimboria-wifi"
$port = 8080

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Lakimboria WiFi Manager Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Check PHP ---
$php = Get-Command php -ErrorAction SilentlyContinue
if (-not $php) {
    Write-Host "[1] PHP not found. Downloading portable PHP..." -ForegroundColor Yellow
    $phpUrl = "https://windows.php.net/downloads/releases/php-8.3.12-nts-Win32-vs16-x64.zip"
    $zipPath = "$env:TEMP\php.zip"
    $phpDir = "$dir\php"
    Invoke-WebRequest -Uri $phpUrl -OutFile $zipPath
    New-Item -ItemType Directory -Path $phpDir -Force | Out-Null
    Expand-Archive -Path $zipPath -DestinationPath $phpDir -Force
    Remove-Item $zipPath -Force
    $env:Path = "$phpDir;$env:Path"
    Write-Host "  PHP installed at $phpDir" -ForegroundColor Green
}

Write-Host "  PHP: $(php -v | Select-Object -First 1)" -ForegroundColor Green

# --- Download repo ---
Write-Host "[2] Downloading Lakimboria..." -ForegroundColor Yellow
if (Test-Path $dir) {
    Write-Host "  Updating existing installation..."
    Push-Location $dir
    & git pull 2>$null
    Pop-Location
} else {
    $zipUrl = "$repo/archive/refs/heads/main.zip"
    $zipPath = "$env:TEMP\lakimboria.zip"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
    Move-Item "$env:TEMP\lakimboria-wifi-main" $dir -Force
    Remove-Item $zipPath -Force
}
Write-Host "  Downloaded to $dir" -ForegroundColor Green

# --- Start server ---
Write-Host "[3] Starting server..." -ForegroundColor Yellow
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "php"
$psi.Arguments = "-S 0.0.0.0:$port -t `"$dir\mikhmon`""
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$p = [System.Diagnostics.Process]::Start($psi)
$p.Id | Out-File "$env:TEMP\lakimboria.pid"
Start-Sleep -Seconds 1

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Lakimboria WiFi Manager is running!" -ForegroundColor Green
Write-Host "  Dashboard : http://localhost:$port" -ForegroundColor Green
Write-Host "  Login     : mikhmon / 1234" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Start-Process "http://localhost:$port"
