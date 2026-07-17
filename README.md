# 📡 Lakimboria WiFi Manager

A beautiful, simple, and powerful MikroTik Hotspot management system tailored specifically for Tanzania. 

Created & Developed by **Deeplearn Technologies**.

---

## 🇹🇿 Sifa Kuu (Key Features)

* **Swahili & English Portal:** A beautiful, responsive, and modern Swahili captive portal design (Blue & Green Gradient theme).
* **TZS Currency Support:** Native support for Tanzanian Shilling (TZS) for all vouchers, prices, and sales reports.
* **Voucher Generator:** Easily generate username/password vouchers, single-code vouchers, or bulk batches.
* **Live Sales Reports:** Track daily, weekly, and monthly sales with custom PDF and thermal printing support.
* **Easy Windows App:** Launch the server with a single click using our custom GUI desktop app—no terminal or coding needed!

---

## 🚀 Jinsi ya Kufunga (Quick Installation)

Fuata hatua hizi tatu rahisi kuanza:

### Hatua ya 1: Weka Kwenye Router yako ya MikroTik (Run on Router)
Fungua **Terminal** kwenye WinBox yako ya MikroTik na uweke amri hii moja kisha bonyeza **Enter**:

```rsc
/tool fetch url="https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.rsc" dst-path=install.rsc; /import install.rsc
```
> **Nini kitatokea?** Amri hii itafungua huduma ya API ya router, na kupakua kiotomatiki kurasa nzuri za kujisajili za Swahili (captive portal) kwenye Router yako.

---

### Hatua ya 2: Washa Programu kwenye Kompyuta (Run Dashboard)

#### A) Njia Rahisi (Windows Desktop App)
1. Pakua faili ya **`LakimboriaWiFiManager.exe`** kutoka kwenye [Releases Page](https://github.com/Abdulnasserh/lakimboria-wifi/releases).
2. Weka faili hilo ndani ya folda la mradi kisha lifungue (double-click).
3. Bonyeza kitufe cha **"Start Server"**. Itapangilia kila kitu na kufungua kivinjari chako kiotomatiki!

#### B) Njia ya Amri Moja (PowerShell - Windows Admin)
Kama unataka kufunga kwa amri moja bila kupakua programu:
```powershell
irm https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.ps1 | iex
```

#### C) Njia ya macOS au Linux (Terminal)
Fungua Terminal yako na uweke amri hii:
```bash
curl -sSL https://raw.githubusercontent.com/Abdulnasserh/lakimboria-wifi/main/install.sh | bash
```

---

### Hatua ya 3: Ingia na Unganisha na Router (Login & Connect)

1. Fungua kivinjari chako (Chrome, Edge, nk.) na nenda kwenye: **`http://localhost:8081`**
2. Ingia kwa kutumia taarifa hizi:
   * **Username:** `mikhmon`
   * **Password:** `1234`
3. Baada ya kuingia, nenda kwenye **Settings → Add Router** na ujaze:
   * **Session Name:** `hotspot`
   * **IP Router:** Weka IP ya router yako (mfano: `192.168.88.1`)
   * **Username:** `admin` (au jina lingine la MikroTik)
   * **Password:** Nywila ya router yako
   * **Currency:** Chagua `TZS` (Tanzanian Shilling)
4. Bonyeza **Save** kisha **Connect**. Hongera! Uko tayari kuanza kuuza vocha.

---

## 🛠️ Kutatua Changamoto (Troubleshooting)

#### 1. Router haitaki kuunganisha kwenye kompyuta (Mikhmon Status: Not Connected)
* Hakikisha kuwa umewasha API kwenye router yako. Unaweza kufanya hivi kwa kwenda kwenye WinBox: **IP → Services** na uhakikishe kuwa `api` ipo hai (port `8728`).
* Hakikisha IP ya router uliyoweka kwenye dashboard ni sahihi.

#### 2. Kwenye Simu, Kurasani bado haionekani katika Kiswahili au muonekano mpya
* Hakikisha kwenye WinBox yako katika **IP → Hotspot → Server Profiles**, profile yako imeelekezwa kutumia folda la `hotspot` kama HTML Directory.

#### 3. Programu ya `.exe` haitaki kufunguka kwenye Windows
* Hakikisha kuwa unayo **PowerShell** na umeruhusu kufungua programu kama msimamizi (Administrator). Faili hili ni salama na linaendeshwa kwa kutumia msimbo asili wa Windows.

---

## 💻 Tech Stack & Credits

* **Dashboard:** Modified Mikhmon V3 PHP backend by Laksamadi Guko.
* **Captive Portal:** Customized HTML5, CSS3, & JS with offline MD5 hashing.
* **Tanzania Edition:** Fully redesigned, translated to Swahili, and localized with TZS currency support by **Deeplearn Technologies**.

---

## 📝 License & Copyright

Mikhmon is open-source under GPLv2.  
**Lakimboria WiFi Manager — Tanzania Custom Edition** © 2025 Deeplearn Technologies.
