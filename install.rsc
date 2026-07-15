# Lakimboria WiFi Manager — Auto Installer
# Run on MikroTik via: /import install.rsc
# Or paste directly into Terminal/SSH

# !!! REPLACE YOUR_USER with your GitHub username before running !!!
:local GITHUB "https://raw.githubusercontent.com/YOUR_USER/mikhmon-tz/main"
:local IFACE "ether2"
:local SERVERNAME "hotspot"
:local LAKIMBORIAURL "http://192.168.1.100:8080"

:put "========================================="
:put "  Lakimboria WiFi Manager"
:put "========================================="
:put ""

# ---- 1. Enable API service ----
:put "[1] Enabling API service..."
/ip service set api disabled=no
/ip service set api-ssl disabled=no
:put "  API enabled on port 8728"

# ---- 2. Enable hotspot on interface ----
:put "[2] Setting up hotspot on $IFACE..."
/ip hotspot add interface=$IFACE name=$SERVERNAME disabled=no

# ---- 3. Configure hotspot profile ----
:put "[3] Configuring hotspot profile..."
/ip hotspot profile set [find] dns-name="$SERVERNAME.local" html-directory=hotspot
:put "  DNS name: $SERVERNAME.local"

# ---- 4. Download custom hotspot pages ----
:put "[4] Downloading custom hotspot pages..."

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

:local DIR "hotspot"

:foreach FILE in=$FILES do={
    :put "  Downloading $FILE..."
    /tool fetch url="$GITHUB/hotspot/$FILE" dst-path="$DIR/$FILE"
}

:put ""

# ---- 5. Download CSS ----
:put "  Downloading CSS..."
/tool fetch url="$GITHUB/hotspot/css/style.css" dst-path="hotspot/css/style.css"

# ---- 6. Download images ----
:put "  Downloading images..."
/tool fetch url="$GITHUB/hotspot/img/bg.jpeg" dst-path="hotspot/img/bg.jpeg"
/tool fetch url="$GITHUB/hotspot/img/bg1.jpeg" dst-path="hotspot/img/bg1.jpeg"
/tool fetch url="$GITHUB/hotspot/img/bg2.jpeg" dst-path="hotspot/img/bg2.jpeg"
/tool fetch url="$GITHUB/hotspot/img/bg3.jpeg" dst-path="hotspot/img/bg3.jpeg"

# ---- 7. Update conf.js with Mikhmon URL ----
:put "[5] Updating conf.js..."
:local CONF [/file get hotspot/conf.js contents]
:local NEWCONF [:toarray ""]
:foreach LINE in=$CONF do={
    :if ([:pick $LINE 0 5] = "url :") do={
        :set NEWCONF ($NEWCONF . "url : \"$LAKIMBORIAURL\",\n")
    } else={
        :set NEWCONF ($NEWCONF . $LINE . "\n")
    }
}
/file set hotspot/conf.js contents=$NEWCONF

# ---- 8. Create default admin user ----
:put "[6] Creating admin bypass user..."
/ip hotspot user add name=admin password=admin profile=default comment=admin-bypass

# ---- 9. Display summary ----
:put ""
:put "========================================="
:put "  INSTALLATION COMPLETE!"
:put "========================================="
:put "  Interface      : $IFACE"
:put "  Server Name    : $SERVERNAME"
:put "  Lakimboria URL : $LAKIMBORIAURL"
:put "  Admin User     : admin / admin"
:put ""
:put "  WHAT TO DO NEXT:"
:put "  1. On your PC: run setup-windows.bat or setup-macos.sh"
:put "  2. Open http://localhost:8080 in browser"
:put "  3. Login with: mikhmon / 1234"
:put "  4. Add this router (IP: $IP, user: admin, pass: your-password)"
:put "  5. Set currency to TZS in Settings"
:put "========================================="
