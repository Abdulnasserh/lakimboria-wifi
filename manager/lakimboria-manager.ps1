Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$basePath = Split-Path -Parent $scriptPath
$mikhmonPath = Join-Path $basePath "mikhmon"
$phpDir = Join-Path $basePath "php"
$phpExe = if (Test-Path (Join-Path $phpDir "php.exe")) { Join-Path $phpDir "php.exe" } else { "php" }
$serverPort = 8080
$global:process = $null

$form = New-Object System.Windows.Forms.Form
$form.Text = "Lakimboria WiFi Manager"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell).Source)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# System Tray Icon Setup
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = $form.Icon
$notifyIcon.Text = "Lakimboria WiFi Manager"
$notifyIcon.Visible = $false

$contextMenu = New-Object System.Windows.Forms.ContextMenu
$menuShow = New-Object System.Windows.Forms.MenuItem("Show Manager")
$menuStop = New-Object System.Windows.Forms.MenuItem("Stop Server")
$menuExit = New-Object System.Windows.Forms.MenuItem("Exit")
$contextMenu.MenuItems.AddRange(@($menuShow, $menuStop, $menuExit))
$notifyIcon.ContextMenu = $contextMenu

$title = New-Object System.Windows.Forms.Label
$title.Text = "Lakimboria WiFi Manager"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$title.Size = New-Object System.Drawing.Size(460, 40)
$title.Location = New-Object System.Drawing.Point(20, 15)
$title.TextAlign = "MiddleCenter"
$form.Controls.Add($title)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Status: Stopped"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$statusLabel.Size = New-Object System.Drawing.Size(200, 25)
$statusLabel.Location = New-Object System.Drawing.Point(20, 65)
$form.Controls.Add($statusLabel)

$statusDot = New-Object System.Windows.Forms.Label
$statusDot.Text = "●"
$statusDot.ForeColor = "Red"
$statusDot.Font = New-Object System.Drawing.Font("Segoe UI", 14)
$statusDot.Size = New-Object System.Drawing.Size(20, 25)
$statusDot.Location = New-Object System.Drawing.Point(145, 63)
$form.Controls.Add($statusDot)

$startBtn = New-Object System.Windows.Forms.Button
$startBtn.Text = "Start Server"
$startBtn.Size = New-Object System.Drawing.Size(130, 35)
$startBtn.Location = New-Object System.Drawing.Point(20, 100)
$startBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$startBtn.BackColor = "ForestGreen"
$startBtn.ForeColor = "White"
$form.Controls.Add($startBtn)

$stopBtn = New-Object System.Windows.Forms.Button
$stopBtn.Text = "Stop Server"
$stopBtn.Size = New-Object System.Drawing.Size(130, 35)
$stopBtn.Location = New-Object System.Drawing.Point(170, 100)
$stopBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$stopBtn.BackColor = "DarkRed"
$stopBtn.ForeColor = "White"
$stopBtn.Enabled = $false
$form.Controls.Add($stopBtn)

$openBtn = New-Object System.Windows.Forms.Button
$openBtn.Text = "Open Dashboard"
$openBtn.Size = New-Object System.Drawing.Size(130, 35)
$openBtn.Location = New-Object System.Drawing.Point(320, 100)
$openBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$openBtn.Enabled = $false
$form.Controls.Add($openBtn)

$urlLabel = New-Object System.Windows.Forms.Label
$urlLabel.Text = "http://localhost:$serverPort"
$urlLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Underline)
$urlLabel.ForeColor = "Blue"
$urlLabel.Size = New-Object System.Drawing.Size(200, 20)
$urlLabel.Location = New-Object System.Drawing.Point(350, 70)
$urlLabel.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($urlLabel)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ReadOnly = $true
$logBox.ScrollBars = "Vertical"
$logBox.Size = New-Object System.Drawing.Size(460, 180)
$logBox.Location = New-Object System.Drawing.Point(20, 150)
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logBox.BackColor = "Black"
$logBox.ForeColor = "Lime"
$form.Controls.Add($logBox)

$loginLabel = New-Object System.Windows.Forms.Label
$loginLabel.Text = "Login: mikhmon / 1234  |  Created by Deeplearn Technologies"
$loginLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
$loginLabel.Size = New-Object System.Drawing.Size(400, 15)
$loginLabel.Location = New-Object System.Drawing.Point(20, 340)
$form.Controls.Add($loginLabel)

function Write-Log {
    param([string]$msg)
    $logBox.AppendText("[$([DateTime]::Now.ToString('HH:mm:ss'))] $msg`r`n")
    $logBox.Select($logBox.TextLength, 0)
    $logBox.ScrollToCaret()
}

function Find-PhpExe {
    $candidates = @(
        (Join-Path $phpDir "php.exe"),
        "php"
    )
    foreach ($c in $candidates) {
        try {
            $v = & $c -v 2>&1 | Out-String
            if ($v -match "PHP") { return $c }
        } catch {}
    }
    return $null
}

function Install-Php {
    Write-Log "PHP not found. Downloading portable PHP..."
    $phpUrl = "https://downloads.php.net/~windows/releases/archives/php-8.3.12-nts-Win32-vs16-x64.zip"
    $zipPath = Join-Path $basePath "php.zip"
    try {
        $web = New-Object System.Net.WebClient
        $web.DownloadFile($phpUrl, $zipPath)
        Write-Log "Downloaded PHP. Extracting..."
        if (-not (Test-Path $phpDir)) { New-Item -ItemType Directory -Path $phpDir -Force | Out-Null }
        Expand-Archive -Path $zipPath -DestinationPath $phpDir -Force
        Remove-Item $zipPath -Force
        Write-Log "PHP installed at $phpDir"
        return (Join-Path $phpDir "php.exe")
    } catch {
        Write-Log "ERROR: Failed to download PHP: $_"
        return $null
    }
}

function Start-Server {
    $exe = Find-PhpExe
    if (-not $exe) {
        $exe = Install-Php
        if (-not $exe) {
            [System.Windows.Forms.MessageBox]::Show("Could not find or install PHP. Install it manually from https://windows.php.net", "Error", "OK", "Error")
            return
        }
    }
    if (-not (Test-Path $mikhmonPath)) {
        [System.Windows.Forms.MessageBox]::Show("mikhmon folder not found next to this app.", "Error", "OK", "Error")
        return
    }
    Write-Log "Starting server on port $serverPort..."
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.Arguments = "-S 0.0.0.0:$serverPort -t `"$mikhmonPath`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $global:process = [System.Diagnostics.Process]::Start($psi)
    Start-Sleep -Seconds 1
    if (-not $global:process.HasExited) {
        $statusLabel.Text = "Status: Running"
        $statusDot.ForeColor = "Lime"
        $startBtn.Enabled = $false
        $stopBtn.Enabled = $true
        $openBtn.Enabled = $true
        Write-Log "Server running at http://localhost:$serverPort"
        $global:process.OutputDataReceived.Add({ if ($data = $_.Data) { Write-Log $data } })
        $global:process.BeginOutputReadLine()
        $global:process.ErrorDataReceived.Add({ if ($data = $_.Data) { Write-Log "ERROR: $data" } })
        $global:process.BeginErrorReadLine()
    } else {
        Write-Log "Server failed to start"
    }
}

function Stop-Server {
    if ($global:process -and -not $global:process.HasExited) {
        $global:process.Kill()
        $global:process.Dispose()
        $global:process = $null
        Write-Log "Server stopped"
    }
    $statusLabel.Text = "Status: Stopped"
    $statusDot.ForeColor = "Red"
    $startBtn.Enabled = $true
    $stopBtn.Enabled = $false
    $openBtn.Enabled = $false
}

$startBtn.Add_Click({ Start-Server })
$stopBtn.Add_Click({ Stop-Server })
$openBtn.Add_Click({ Start-Process "http://localhost:$serverPort" })
$urlLabel.Add_Click({ Start-Process "http://localhost:$serverPort" })

# Form events
$form.Add_Resize({
    if ($form.WindowState -eq "Minimized") {
        $form.Hide()
        $notifyIcon.Visible = $true
        $notifyIcon.ShowBalloonTip(1000, "Lakimboria WiFi Manager", "App is running in system tray.", [System.Windows.Forms.ToolTipIcon]::Info)
    }
})

$menuShow.Add_Click({
    $form.Show()
    $form.WindowState = "Normal"
    $notifyIcon.Visible = $false
})

$menuStop.Add_Click({ Stop-Server })

$menuExit.Add_Click({
    Stop-Server
    $notifyIcon.Dispose()
    $form.Close()
})

$notifyIcon.Add_DoubleClick({
    $form.Show()
    $form.WindowState = "Normal"
    $notifyIcon.Visible = $false
})

$form.Add_FormClosing({
    param($sender, $e)
    if ($global:process -and -not $global:process.HasExited) {
        $result = [System.Windows.Forms.MessageBox]::Show("Server is still running. Stop it before closing?", "Server Running", "YesNo", "Warning")
        if ($result -eq "Yes") { 
            Stop-Server 
            $notifyIcon.Dispose()
        } else {
            $e.Cancel = $true
            $form.Hide()
            $notifyIcon.Visible = $true
        }
    } else {
        $notifyIcon.Dispose()
    }
})

# Auto-start on launch
$form.Add_Shown({
    Start-Server
    if ($global:process -and -not $global:process.HasExited) {
        Start-Process "http://localhost:$serverPort"
        # Optional: Auto minimize to tray on startup
        Start-Sleep -Seconds 1
        $form.Hide()
        $notifyIcon.Visible = $true
    }
})

Write-Log "Lakimboria WiFi Manager v1.0"
Write-Log "Initializing automatic server startup..."

[void]$form.ShowDialog()
