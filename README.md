# Robot-T430 Web Application

Web-based administration interface for the Robot-T430 Raspberry Pi CM4 device. Provides device configuration, network management, application settings, and system administration through a browser.

## What this UI does

Five pages, reached from the top navigation.

**Home** — device information: model, release, hostname, addresses, uptime.

**Communications**

- **SCADA server** — connection state, last contact, station and server URL,
  and a button that takes this terminal off its SCADA server and puts it back.
- **Network interfaces** — the wired interface, DHCP or static, through
  NetworkManager.
- **Time** — NTP servers and the terminal's clock.
- **Websocket services** — the three serial bridges this terminal runs: the
  **card reader** (wsRobot, port 8100), the **barcode scanner**
  (`wsrobot@scanner`, 8102) and the **scale** (wsScale, 8101). Each has its
  port, its serial device, its output format and its running state.

**Application**

- **Startup** — which application the kiosk session launches: Desktop, Robot
  Browser, Chrome Kiosk, Robot App, or Device Web App.
- **Application engine** — what this terminal *is* (Function), which API the app
  talks (Protocol), which indicator is on the bench (Scale), the tag name, and
  two URLs: **Setup URL**, where the terminal is configured from, and
  **Transaction URL**, where the app posts its work. Both are handed to the app.
- **Device web app** — see below.

**Administration** — change the web UI password.

**Contact** — support details.

## Device web app, installed at the terminal

A terminal can be given its application **at the terminal**, from this page,
with no SCADA server involved.

Upload a `.tar.gz` bundle on the Application page and it is installed by exactly
the code that installs one the SCADA server sends — `robot_device_webapp` in
robot-scada-client, reached through the `webapp-config` helper. Nothing about
the install is a special local path, so an app written against a SCADA server
runs here unchanged.

The card shows:

- **Installed** — the app's name and version, and its vendor if it declares one.
- **Serving version** — every version still on the terminal. Going back to the
  one before does not need the network that broke.
- **Upload a bundle** — the file, and what happened to it.

**The bundle contract.** A bundle is a gzipped tar of a built app carrying a
`manifest.json` at its root:

```json
{
  "slug": "device-webapp-template",
  "name": "Packhouse Terminal",
  "version": "1.4.0",
  "vendor": "Radical Electronic Systems",
  "supports": ["SCALE", "SCANNER", "TERMINAL"]
}
```

`slug` and `version` are required — the bundle says which app and which version
it is, so nothing on the page has to be told. `supports` is what fills the
**Function** list: a terminal cannot be set to a function its app has never had
a screen for, and the list stops being something written into a CGI that goes
stale the day an app gains one.

**How it is served.** Installed under `/var/www/apps/<slug>/`, served by
robot-scada-client on `127.0.0.1:8081`, and opened by `pi-webapp.sh` when the
startup application is `DEVICE_WEBAPP`. An app installed here is marked as
managed here, so the server's next offer does not replace it within the minute.
`DEVICE_WEBAPP_SLUG` in `/etc/robot/app.conf` says which app runs when a
terminal holds more than one.

**Running without a server.** Disconnecting on the Communications page stops
robot-scada-client *and* sets `server.conf` aside, so the terminal stops obeying
what a server last told it. The launchers then use the terminal's own settings,
and `pi-webapp.sh` serves the app installed here. Reconnecting hands it all
back — nothing is deleted.

Saving the Application page writes the app's own `config.json` through
robot-scada-client's writer, so the configuration a standalone terminal makes is
the file a provisioned one gets: same fields, same shape, same path.

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
  webapp-config          Root helper: install, activate and configure the app
  scada-config           Root helper: disconnect from the SCADA server
  ttysocket-config       Root helper: the serial bridges
  ntp-config             Root helper: the clock
  www-nmcli              Sudoers rules for all of the above
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

### Privileged helpers

The CGI runs as `www-data`. Anything it cannot do as that user goes through a
helper that accepts only the settings its page owns and validates them before
writing — a web request must not be able to repoint the serial bridge at an
arbitrary device, unpack an archive anywhere under `/var/www`, or hand systemd
an arbitrary unit name. All of them are shipped by `sync.sh` and named in
`deploy/www-nmcli`, which becomes `/etc/sudoers.d/www-nmcli`:

```
www-data ALL=(ALL) NOPASSWD: /usr/bin/nmcli
www-data ALL=(root) NOPASSWD: /usr/local/sbin/ttysocket-config
www-data ALL=(root) NOPASSWD: /usr/local/sbin/ntp-config
www-data ALL=(root) NOPASSWD: /usr/local/sbin/webapp-config
www-data ALL=(root) NOPASSWD: /usr/local/sbin/scada-config
```

A helper that is called but not named here fails silently: `sudo` asks
`www-data` for a password it does not have, and the page shows nothing.

Network itself is managed by NetworkManager, and the Communications page
switches the wired interface between DHCP and static.

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
