# Lakimboria WiFi Manager

MikroTik hotspot management for Tanzania — TZS currency, Swahili language, voucher generation, sales reports.

Created by **Deeplearn Technologies**.

---

## Quick Install

### 1. Install Dashboard (one command)

**Windows (PowerShell Admin):**
```powershell
irm https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.ps1 | iex
```

**macOS / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.sh | bash
```

Opens at **http://localhost:8080** — Login: `mikhmon` / `1234`

### 2. Install on MikroTik Router (one command)

SSH into your MikroTik and run:

```rsc
/tool fetch url="https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.rsc" dst-path=install.rsc
/import install.rsc
```

This enables API, sets up hotspot, and downloads the captive portal pages.

### 3. Connect Dashboard to Router

In Lakimboria: **Settings → Add Router** → Enter MikroTik IP, username, password → Set currency to `TZS`

---

## Download Windows App

Download the **Lakimboria WiFi Manager** desktop app from the [Releases page](https://github.com/Abdulnasserh/lakimboria-wifi/releases).  
Double-click to start/stop the server with a simple GUI — no terminal needed.

---

## Manual Setup

### Requirements

- **PHP 8.0+** with CLI and mbstring
- **MikroTik RouterOS** 6.x / 7.x with hotspot configured

### Run without installer

```bash
git clone https://github.com/Abdulnasserh/lakimboria-wifi.git
cd lakimboria-wifi/mikhmon
php -S 0.0.0.0:8080
```

### Upload hotspot pages manually

Upload `hotspot/` folder contents to MikroTik via WinBox (Files → hotspot/).

---

## Features

- TZS currency (Tanzania Shilling)
- Swahili (Kiswahili) and English language
- Voucher generation (user/pass or single code)
- User management with profiles
- Sales reports with live income tracking
- Multi-router support
- Voucher printing (thermal, standard, QR)
- WhatsApp sharing
- Voucher editor

---

## Stack

- **PHP backend** — Mikhmon V3 (hotspot monitor)
- **Captive portal** — Custom HTML/JS hotspot pages
- **MikroTik API** — routeros-api class

---

## License

GPLv2 — Original Mikhmon by Laksamadi Guko  
Tanzania Edition © 2025 Deeplearn Technologies
