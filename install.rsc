# Lakimboria WiFi Manager — Auto Installer for MikroTik
# Run on MikroTik via: /import install.rsc
# Or paste directly into Terminal/SSH
#
# IMPORTANT: Before running, change LAKIMBORIAURL below to match
# the static IP address of your Windows PC running the manager.
# Example: If your PC IP is 192.168.88.200, set it to http://192.168.88.200:8081
# NOTE: If you used install.ps1 on Windows, this file is auto-configured with your IP.

:local GITHUB "https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main"
:local SERVERNAME "hotspot"
:local LAKIMBORIAURL "http://192.168.88.200:8081"

:put "========================================="
:put "  Lakimboria WiFi Manager Installer"
:put "========================================="
:put ""

# ---- 1. Enable API service ----
:put "[1] Enabling API service..."
/ip service set api disabled=no
/ip service set api-ssl disabled=no
:put "  API enabled on port 8728"

# ---- 2. Create directory structure ----
:put "[2] Creating directory structure..."
# RouterOS doesn't have a mkdir command, so we create dummy files to force folder creation
/file print file="hotspot/css/dummy"
/file print file="hotspot/img/dummy"
/file print file="hotspot/xml/dummy"
:delay 2s

# ---- 3. Download captive portal files ----
:put "[3] Downloading captive portal files..."

# Download each hotspot file individually for RouterOS 6.x and 7.x compatibility
:put "  Downloading login.html..."
/tool fetch url=($GITHUB . "/hotspot/login.html") dst-path="hotspot/login.html"
:put "  Downloading alogin.html..."
/tool fetch url=($GITHUB . "/hotspot/alogin.html") dst-path="hotspot/alogin.html"
:put "  Downloading logout.html..."
/tool fetch url=($GITHUB . "/hotspot/logout.html") dst-path="hotspot/logout.html"
:put "  Downloading error.html..."
/tool fetch url=($GITHUB . "/hotspot/error.html") dst-path="hotspot/error.html"
:put "  Downloading radvert.html..."
/tool fetch url=($GITHUB . "/hotspot/radvert.html") dst-path="hotspot/radvert.html"
:put "  Downloading redirect.html..."
/tool fetch url=($GITHUB . "/hotspot/redirect.html") dst-path="hotspot/redirect.html"
:put "  Downloading rlogin.html..."
/tool fetch url=($GITHUB . "/hotspot/rlogin.html") dst-path="hotspot/rlogin.html"
:put "  Downloading status.html..."
/tool fetch url=($GITHUB . "/hotspot/status.html") dst-path="hotspot/status.html"
:put "  Downloading md5.js..."
/tool fetch url=($GITHUB . "/hotspot/md5.js") dst-path="hotspot/md5.js"
:put "  Downloading conf.js..."
/tool fetch url=($GITHUB . "/hotspot/conf.js") dst-path="hotspot/conf.js"
:put "  Downloading errors.txt..."
/tool fetch url=($GITHUB . "/hotspot/errors.txt") dst-path="hotspot/errors.txt"
:put "  Downloading errors-en.txt..."
/tool fetch url=($GITHUB . "/hotspot/errors-en.txt") dst-path="hotspot/errors-en.txt"
:put "  Downloading favicon.ico..."
/tool fetch url=($GITHUB . "/hotspot/favicon.ico") dst-path="hotspot/favicon.ico"

# Download CSS
:put "  Downloading CSS..."
/tool fetch url=($GITHUB . "/hotspot/css/style.css") dst-path="hotspot/css/style.css"

# Download SVGs
:put "  Downloading icons..."
/tool fetch url=($GITHUB . "/hotspot/img/user.svg") dst-path="hotspot/img/user.svg"
/tool fetch url=($GITHUB . "/hotspot/img/password.svg") dst-path="hotspot/img/password.svg"
/tool fetch url=($GITHUB . "/hotspot/img/voucher.svg") dst-path="hotspot/img/voucher.svg"

# Clean up dummy files
/file remove "hotspot/css/dummy.txt"
/file remove "hotspot/img/dummy.txt"
/file remove "hotspot/xml/dummy.txt"

# ---- 4. Configure hotspot profile ----
:put "[4] Applying captive portal to all hotspot profiles..."
/ip hotspot profile set [find] html-directory=hotspot
:put "  All Hotspot profiles updated to use Lakimboria pages."

# ---- 5. Update conf.js with Lakimboria URL ----
:put "[5] Setting Lakimboria Server URL in conf.js..."
:local CONFJS ("var config = {\r\n  loginvc : \"Weka Kodi ya Vocha kisha bonyeza Unganisha.\",\r\n  loginup : \"Weka Jina la Mtumiaji na Nywila kisha bonyeza Unganisha.\",\r\n  voucherCode : \"Kodi ya Vocha\",\r\n  setCase : \"none\",\r\n  defaultMode : \"voucher\",\r\n  theme : \"default\",\r\n  url : \"" . $LAKIMBORIAURL . "\",\r\n  SessionName : \"" . $SERVERNAME . "\",\r\n}\r\n")
/file set "hotspot/conf.js" contents=$CONFJS

# ---- 6. Display summary ----
:put ""
:put "========================================="
:put "  INSTALLATION COMPLETE!"
:put "========================================="
:put ("  Server Name    : " . $SERVERNAME)
:put ("  Lakimboria URL : " . $LAKIMBORIAURL)
:put ""
:put "  WHAT TO DO NEXT:"
:put "  1. On your PC: run setup-windows.bat or setup-macos.sh"
:put "  2. Open http://localhost:8081 in browser"
:put "  3. Login with: mikhmon / 1234"
:put "  4. Add this router in Settings"
:put "========================================="
