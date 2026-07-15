<?php
/**
 * Automated MikroTik Hotspot Setup + Custom Login Page Installer
 *
 * Usage: php setup-hotspot.php <ip> <user> <password> <interface> [mikhmon_url] [session_name]
 *
 * Example:
 *   php setup-hotspot.php 192.168.88.1 admin pass ether2
 *   php setup-hotspot.php 192.168.88.1 admin pass ether2 http://192.168.1.100:8080 myhotspot
 */

require_once __DIR__ . '/lib/routeros_api.class.php';

// ---- Parse args ----
if ($argc < 5) {
    echo "Usage: php setup-hotspot.php <ip> <user> <password> <interface> [mikhmon_url] [session_name]\n";
    echo "  <ip>          - MikroTik IP address\n";
    echo "  <user>        - MikroTik username (admin or API user)\n";
    echo "  <password>    - MikroTik password\n";
    echo "  <interface>   - Interface for hotspot (e.g., ether2, wlan1)\n";
    echo "  [mikhmon_url] - Your Mikhmon server URL (optional, default: http://localhost:8080)\n";
    echo "  [session_name]- Mikhmon session name (optional, default: hotspot)\n";
    exit(1);
}

$ip       = $argv[1];
$user     = $argv[2];
$pass     = $argv[3];
$iface    = $argv[4];
$mikhmon  = $argv[5] ?? 'http://localhost:8080';
$sesname  = $argv[6] ?? 'hotspot';

$hotspot_dir = __DIR__ . '/../new-hotspot-01';

echo "=== MikroTik Hotspot Auto Setup ===\n\n";

// ---- 1. Connect via API ----
echo "[1] Connecting to $ip...\n";
$API = new RouterosAPI();
$API->debug = false;
if (!$API->connect($ip, $user, $pass)) {
    echo "ERROR: Failed to connect to $ip\n";
    exit(1);
}
echo "  Connected.\n";

// ---- 2. Check if hotspot already enabled ----
echo "[2] Checking current hotspot status...\n";
$hotspots = $API->comm('/ip/hotspot/print');
$found = false;
foreach ($hotspots as $hs) {
    if ($hs['interface'] === $iface) {
        $found = true;
        echo "  Hotspot already active on $iface (server: {$hs['name']}). Skipping setup.\n";
        break;
    }
}

if (!$found) {
    // ---- 3. Enable hotspot on interface ----
    echo "[3] Enabling hotspot on $iface...\n";
    $API->comm('/ip/hotspot/add', [
        'interface' => $iface,
        'name'      => $sesname,
    ]);
    echo "  Hotspot server '{$sesname}' created on $iface.\n";

    // ---- 4. Configure hotspot server profile ----
    echo "[4] Configuring hotspot server profile...\n";
    $API->comm('/ip/hotspot/profile/set', [
        'numbers'   => '0',
        'dns-name'  => $sesname . '.local',
        'html-directory' => 'hotspot',
    ]);
    echo "  DNS name set to {$sesname}.local\n";
}

// ---- 5. Create hotspot users (admin bypass) ----
echo "[5] Creating admin bypass user...\n";
$API->comm('/ip/hotspot/user/add', [
    'name'     => 'admin',
    'password' => 'admin',
    'profile'  => 'default',
    'comment'  => 'admin-bypass',
]);
echo "  Admin user created (username: admin, password: admin).\n";

// ---- 6. Upload custom hotspot pages via FTP ----
echo "[6] Uploading custom hotspot pages via FTP...\n";

$conn_id = ftp_connect($ip, 21, 30);
if (!$conn_id) {
    echo "  WARNING: FTP connection failed. You'll need to upload files manually.\n";
    echo "  Upload the contents of '{$hotspot_dir}' to the router's hotspot directory via WinBox (Files).\n";
} else {
    if (!ftp_login($conn_id, $user, $pass)) {
        echo "  WARNING: FTP login failed. Upload files manually via WinBox.\n";
        ftp_close($conn_id);
    } else {
        ftp_pasv($conn_id, true);

        // Update conf.js with Mikhmon URL + session name
        $confPath = $hotspot_dir . '/conf.js';
        $confContent = file_get_contents($confPath);
        $confContent = preg_replace('/url\s*:\s*"[^"]*"/', 'url : "' . $mikhmon . '"', $confContent);
        $confContent = preg_replace('/SessionName\s*:\s*"[^"]*"/', 'SessionName : "' . $sesname . '"', $confContent);
        file_put_contents($confPath, $confContent);
        echo "  conf.js updated: url={$mikhmon}, SessionName={$sesname}\n";

        // Upload all files from new-hotspot-01 to router's hotspot directory
        $files = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($hotspot_dir, RecursiveDirectoryIterator::SKIP_DOTS)
        );
        $count = 0;
        foreach ($files as $file) {
            if ($file->isFile()) {
                $localPath = $file->getRealPath();
                $relativePath = str_replace($hotspot_dir . '/', '', $localPath);

                // Skip hidden files and .git
                if (str_starts_with($relativePath, '.') || str_starts_with($relativePath, 'README.md')) {
                    continue;
                }

                if (ftp_put($conn_id, $relativePath, $localPath, FTP_BINARY)) {
                    $count++;
                    echo "  Uploaded: {$relativePath}\n";
                } else {
                    echo "  FAILED: {$relativePath}\n";
                }
            }
        }
        echo "  Uploaded {$count} files.\n";
        ftp_close($conn_id);
    }
}

$API->disconnect();

echo "\n=== Setup Complete! ===\n";
echo "  Hotspot interface : {$iface}\n";
echo "  Mikhmon URL       : {$mikhmon}\n";
echo "  Session name      : {$sesname}\n";
echo "  Admin user        : admin / admin\n";
echo "\nNext steps:\n";
echo "  1. Add this router to Mikhmon (Login → Add Router)\n";
echo "  2. In Mikhmon Settings: set IP, user, pass, hotspot name, currency (TZS)\n";
echo "  3. Connect a client to {$iface} — they'll see the custom login page\n";
echo "\n";
