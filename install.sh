#!/bin/bash
# Lakimboria WiFi Manager — One-Command Installer (macOS / Linux)
# Usage: curl -sSL https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.sh | bash

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO="https://github.com/Abdulnasserh/lakimboria-wifi"
DIR="$HOME/lakimboria-wifi"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Lakimboria WiFi Manager Installer${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# --- Check/Install PHP ---
if ! command -v php &>/dev/null; then
    echo -e "${YELLOW}[1] PHP not found. Installing...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v brew &>/dev/null; then
            echo -e "${YELLOW}  Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install php
    elif command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y php-cli php-mbstring curl
    elif command -v yum &>/dev/null; then
        sudo yum install -y php-cli php-mbstring curl
    else
        echo -e "${RED}Please install PHP manually: https://php.net${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}  PHP: $(php -v | head -1)${NC}"

# --- Clone/Update repo ---
echo -e "${YELLOW}[2] Downloading Lakimboria...${NC}"
if [ -d "$DIR" ]; then
    echo "  Updating existing installation..."
    cd "$DIR" && git pull
else
    git clone --depth=1 "$REPO.git" "$DIR"
fi
echo -e "${GREEN}  Downloaded to $DIR${NC}"

# --- Start server ---
echo -e "${YELLOW}[3] Starting server...${NC}"
cd "$DIR/mikhmon"
php -S 0.0.0.0:8081 > /tmp/lakimboria-server.log 2>&1 &
echo $! > /tmp/lakimboria.pid
sleep 1

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}  Lakimboria WiFi Manager is running!${NC}"
echo -e "${GREEN}  Dashboard : http://localhost:8081${NC}"
echo -e "${GREEN}  Login     : mikhmon / 1234${NC}"
echo -e "${GREEN}  Stop      : kill \$(cat /tmp/lakimboria.pid)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Open browser
sleep 1
if command -v open &>/dev/null; then open http://localhost:8081
elif command -v xdg-open &>/dev/null; then xdg-open http://localhost:8081
fi
