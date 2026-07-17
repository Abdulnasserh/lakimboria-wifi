#!/bin/bash
# Lakimboria WiFi Manager — Setup (macOS/Linux)

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}  Lakimboria WiFi Manager${NC}"
echo -e "${CYAN}  Powered by Mikhmon — macOS/Linux Setup${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""
echo -e "  ${YELLOW}TIP:${NC} macOS users can download the Mac app from:"
echo -e "  ${CYAN}https://github.com/Abdulnasserh/lakimboria-wifi/releases${NC}"
echo ""

# Check PHP
if ! command -v php &>/dev/null; then
    echo "[1] PHP not found. Installing via Homebrew..."
    if command -v brew &>/dev/null; then
        brew install php
    else
        echo "ERROR: Install PHP manually:"
        echo "  macOS: brew install php"
        echo "  Ubuntu: sudo apt install php-cli php-mbstring"
        exit 1
    fi
fi

echo -e "${GREEN}[1] PHP found: $(php -v | head -1)${NC}"

# Check if Lakimboria files exist
if [ ! -f "$DIR/mikhmon/admin.php" ]; then
    echo "ERROR: Lakimboria files not found. Run this script from the mikhmon-tz folder."
    exit 1
fi

echo -e "${GREEN}[2] Starting Lakimboria server...${NC}"

# Start PHP server in background
cd "$DIR/mikhmon"
php -S 0.0.0.0:8081 > /tmp/lakimboria-server.log 2>&1 &
SERVER_PID=$!
cd "$DIR"

echo -e "${GREEN}[3] Server started (PID: $SERVER_PID)${NC}"

# Open browser
sleep 2
if command -v open &>/dev/null; then
    open http://localhost:8081
  elif command -v xdg-open &>/dev/null; then
    xdg-open http://localhost:8081
fi

echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${GREEN}  Lakimboria WiFi Manager is running at:${NC}"
echo -e "${GREEN}  http://localhost:8081${NC}"
echo ""
echo -e "${GREEN}  Login: mikhmon / 1234${NC}"
echo ""
echo -e "${GREEN}  Stop server: kill $SERVER_PID${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Keep PID for easy kill
echo "$SERVER_PID" > /tmp/lakimboria.pid
echo "Server PID saved to /tmp/lakimboria.pid"
echo "To stop: kill \$(cat /tmp/lakimboria.pid)"
