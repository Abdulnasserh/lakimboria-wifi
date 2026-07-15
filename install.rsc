# Lakimboria WiFi Manager — Auto Installer for MikroTik
# Run on MikroTik via: /import install.rsc
# Or paste directly into Terminal/SSH

:local GITHUB "https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main"
:local SERVERNAME "hotspot"
:local LAKIMBORIAURL "http://192.168.1.100:8080"

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
:delay 1s

# ---- 3. Download captive portal files ----
:put "[3] Downloading captive portal files..."

:local FILES {
    "login.html"
    "alogin.html"
    "logout.html"
    "error.html"
    "radvert.html"
    "redirect.html"
    "rlogin.html"
    "status.html"
    "md5.js"
    "conf.js"
    "errors.txt"
    "errors-en.txt"
    "favicon.ico"
}

:foreach FILE in=$FILES do={
    :put "  Downloading $FILE..."
    /tool fetch url="$GITHUB/hotspot/$FILE" dst-path="hotspot/$FILE"
}

# Download CSS
:put "  Downloading CSS..."
/tool fetch url="$GITHUB/hotspot/css/style.css" dst-path="hotspot/css/style.css"

# Download SVGs
:put "  Downloading icons..."
/tool fetch url="$GITHUB/hotspot/img/user.svg" dst-path="hotspot/img/user.svg"
/tool fetch url="$GITHUB/hotspot/img/password.svg" dst-path="hotspot/img/password.svg"
/tool fetch url="$GITHUB/hotspot/img/voucher.svg" dst-path="hotspot/img/voucher.svg"

# Clean up dummy files
/file remove "hotspot/css/dummy.txt"
/file remove "hotspot/img/dummy.txt"
/file remove "hotspot/xml/dummy.txt"

# ---- 4. Configure hotspot profile ----
:put "[4] Applying captive portal to hotspot profile..."
# Check if profile exists, if so modify, otherwise warn
:local PROFILE [ /ip hotspot profile find where name="default" or dns-name="$SERVERNAME.local" ]
:if ([:len $PROFILE] > 0) do={
    /ip hotspot profile set $PROFILE dns-name="$SERVERNAME.local" html-directory=hotspot
    :put "  Hotspot profile updated to use Lakimboria pages."
} else={
    :put "  WARNING: No hotspot profile found. Please run IP -> Hotspot -> Hotspot Setup first, then run this script again."
}

# ---- 5. Update conf.js with Lakimboria URL ----
:put "[5] Setting Lakimboria Server URL in conf.js..."
/file set "hotspot/conf.js" contents="var config = {\r\n  loginvc : \"Weka Kodi ya Vocha kisha bonyeza Unganisha.\",\r\n  loginup : \"Weka Jina la Mtumiaji na Nywila kisha bonyeza Unganisha.\",\r\n  voucherCode : \"Kodi ya Vocha\",\r\n  setCase : \"none\",\r\n  defaultMode : \"voucher\",\r\n  theme : \"default\",\r\n  url : \"$LAKIMBORIAURL\",\r\n  SessionName : \"hotspot\",\r\n}\r\n"

# ---- 6. Display summary ----
:put ""
:put "========================================="
:put "  INSTALLATION COMPLETE!"
:put "========================================="
:put "  Server Name    : $SERVERNAME"
:put "  Lakimboria URL : $LAKIMBORIAURL"
:put ""
:put "  WHAT TO DO NEXT:"
:put "  1. On your PC: run setup-windows.bat or setup-macos.sh"
:put "  2. Open http://localhost:8080 in browser"
:put "  3. Login with: mikhmon / 1234"
:put "  4. Add this router in Settings"
:put "========================================="
