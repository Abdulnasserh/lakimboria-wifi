# Lakimboria WiFi Manager

Hotspot management system for Tanzania — MikroTik voucher management with TZS currency and Swahili language support. Created by Deeplearn Technologies.

**Stack:**
- **Mikhmon** — PHP web app for managing hotspot users, vouchers, and sales
- **Custom hotspot pages** — Captive portal login page (English/Swahili)

## Quick Start

### 1. On your MikroTik Router (via SSH/Terminal)

```rsc
/tool fetch url="https://raw.githubusercontent.com/YOUR_USER/mikhmon-tz/main/install.rsc" dst-path=install.rsc
/import install.rsc
```

This enables API, configures hotspot, and downloads the captive portal.

### 2. On your PC

**Windows:** Double-click `setup-windows.bat`  
**macOS/Linux:** `chmod +x setup-macos.sh && ./setup-macos.sh`

### 3. Login

Open http://localhost:8080 — Login: `mikhmon` / `1234`

### 4. Add Router

In Lakimboria: Settings → Add Router → Enter your MikroTik IP, user, password → Set currency to `TZS`

## Manual Setup

### Install PHP

**macOS (Homebrew):** `brew install php`  
**Windows:** Download from https://windows.php.net/download/  
**Ubuntu:** `sudo apt install php-cli php-mbstring`

### Run Mikhmon

```bash
cd mikhmon
php -S 0.0.0.0:8080
```

### Install hotspot pages on MikroTik

Upload the `hotspot/` folder contents to your MikroTik via WinBox (Files → hotspot/).

## Features

- TZS currency support (Tanzania Shilling)
- Swahili language (Kiswahili)
- English language
- Voucher generation (username+password or single code)
- User management
- Sales reports
- Live income tracking
- Multi-router support
- Voucher printing (thermal, standard, QR)
- WhatsApp sharing
