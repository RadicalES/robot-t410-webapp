# Robot-T420QT Web Application

Device administration interface for the Robot-T420QT, built as a vanilla JavaScript single-page application targeting the device's Qt5WebKit browser.

## Overview

- **Device**: Robot-T420QT (800x480 resistive touchscreen)
- **Browser**: RBrowser (Qt5WebKit, ~Safari 6-8 level JS engine)
- **Web Server**: Hiawatha with CGI wrapper
- **Transpiler**: Babel (ES5 output, safari 9 target)

## Pages

| Page | Description |
|------|-------------|
| Device | System info (OS, kernel, MAC, startup app) |
| Application | Window manager URL/layout, TTY WebSocket server config |
| Communications | LAN/WiFi network settings with tabbed interface, WiFi AP scanning |
| Administration | Password change, device reboot |
| Contact | Company contact details |

## Project Structure

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

Copy `.env.example` or create `.env`:
```
DEVICE_IP=http://10.224.40.178
DEVICE_USER=root
DEVICE_HOST=10.224.40.178
DEVICE_PASS=temppw
```

See [WORKFLOW.md](WORKFLOW.md) for full build/deploy details and QtWebKit constraints.

## License

(C) 2012-2026 Radical Electronic Systems CC. All rights reserved.
