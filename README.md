# Robot-T430 Web Application

Web-based administration interface for the Robot-T430 Raspberry Pi CM4 device. Provides device configuration, network management, application settings, and system administration through a browser.

## Architecture

The frontend is a vanilla JavaScript single-page application. In development, [Vite](https://vitejs.dev/) serves the frontend locally and proxies CGI requests to the real device. In production, NGINX on the Pi serves static files and executes CGI bash scripts via fcgiwrap.

```
public/                  Frontend SPA source
  index.html             Main page shell with navigation and modals
  robot.js               Core app logic (API calls, layer loading, UI state)
  validation.js          LiveValidation form validation library
  site.css               Styles (CSS custom properties for theming)
  layers/                HTML fragments loaded dynamically (Home, App, Comms)

deploy/                  Device deployment files
  cgi/                   Bash CGI scripts (run on the Pi as www-data)
  nginx.conf             NGINX site config with Basic Auth
  sync.sh                Build + rsync deployment script
  setup-auth.sh          One-time auth setup (creates .htpasswd)
  network-failsafe.sh    Boot-time failsafe to reset network via button press
  network-failsafe.service  Systemd service for the failsafe script
  config/                Example device config files
```

## Getting Started

### Prerequisites

- Node.js (v18+)
- A Robot-T430 device accessible on the network

### Setup

```bash
npm install
cp .env.example .env
```

Edit `.env` with your device's IP address:

```
DEVICE_IP=http://10.224.40.136
DEVICE_USER=robot
DEVICE_HOST=10.224.40.136
```

### Development

```bash
npm run dev
```

Opens the frontend on http://localhost:3000. All `/cgi/*` requests are proxied to the device IP configured in `.env`.

### Build & Deploy

```bash
npm run build     # Babel transpile JS to build/
npm run deploy    # Build + rsync files to device
```

## Device Setup

### NGINX & Authentication

The device uses NGINX with Basic Auth. First-time setup:

```bash
./deploy/setup-auth.sh
```

This installs `apache2-utils`, creates `/etc/nginx/.htpasswd` with the admin user, and reloads NGINX. The password can be changed through the Administration page in the web UI.

### Network Configuration

Network is managed via NetworkManager (nmcli). The web UI allows switching between DHCP and static IP on the Communications page. The CGI script (`setnwk.sh`) requires sudoers access for `www-data`:

```
# /etc/sudoers.d/www-nmcli
www-data ALL=(ALL) NOPASSWD: /usr/bin/nmcli
```

### Network Failsafe

A systemd service checks if the ENTER button (GPIO 5) on the custom keypad is held for 3 seconds during boot. If triggered, it resets the network to DHCP. Deploy with:

```bash
sudo cp deploy/network-failsafe.sh /usr/local/bin/network-failsafe.sh
sudo chmod +x /usr/local/bin/network-failsafe.sh
sudo cp deploy/network-failsafe.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable network-failsafe.service
```

Check failsafe logs with `journalctl -t network-failsafe`.

## License

(C) 2012-2026 Radical Electronic Systems CC. All rights reserved.
