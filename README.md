# Robot-T4x0 Web Application

Device administration web interface for the Robot-T4x0 series devices.

## Branches

| Branch | Device | Description |
|--------|--------|-------------|
| T430 | Robot-T430 (RPi CM4) | Standard build, NGINX, NetworkManager |
| t430-palpi | Robot-T430 (RPi CM4) | Includes PalPi (Paltrack) service support |
| T420QT | Robot-T420 (Qt5WebKit) | Vanilla JS SPA for 800x480 resistive touchscreen |

## Pages

| Page | Description |
|------|-------------|
| Device | System info (OS, kernel, MAC, startup app) |
| Application | Window manager URL/layout, TTY WebSocket server config |
| Communications | LAN/WiFi network settings with tabbed interface, WiFi AP scanning |
| Administration | Password change, device reboot |
| Contact | Company contact details |

## Project Structure (T420QT)

```
public/
  index.html          Main page shell (admin + contact inline)
  robot.js            Core application logic
  validation.js       LiveValidation library (3rd party)
  site.css            Stylesheet
  w3.css              W3.CSS framework
  layers/
    layerHome.html    Device info (loaded dynamically)
    layerApp.html     Application config (loaded dynamically)
    layerComms.html   Communications config (loaded dynamically)
scripts/
  build.sh            Production build script
  deploy.sh           Deploy to device via rsync
.babelrc              Babel config (sourceType: script, safari 9)
vite.config.js        Vite dev server with CGI proxy
.env                  Device IP and credentials (not committed)
```

## Quick Start

```bash
npm install

# Development (proxies CGI calls to device)
npm run dev

# Production build
npm run build

# Build + deploy to device
npm run deploy
```

## Configuration

Create `.env` in the project root:
```
DEVICE_IP=http://<device-ip>
DEVICE_USER=root
DEVICE_HOST=<device-ip>
DEVICE_PASS=<password>
```

See [WORKFLOW.md](WORKFLOW.md) for full build/deploy details and QtWebKit constraints.

## License

(C) 2012-2026 Radical Electronic Systems CC. All rights reserved.
