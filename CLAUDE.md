# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Web-based administration UI for the Robot-T430 Raspberry Pi CM device. The frontend is a vanilla JS single-page application. In development, Vite serves the frontend locally and proxies `/cgi/*` requests to the real device. In production, NGINX on the Pi serves static files and executes CGI bash scripts via fcgiwrap.

## Commands

- **Dev server:** `npm run dev` (Vite on port 3000, proxies `/cgi/*` to device IP in `.env`)
- **Build:** `npm run build` (Babel transpile robot.js + validation.js to `build/`)
- **Deploy to device:** `npm run deploy` (builds then rsync static files + CGI scripts to device)

Configure the target device in `.env` (`DEVICE_IP`, `DEVICE_USER`, `DEVICE_HOST`).

## Architecture

```
public/              → Frontend SPA (served by Vite in dev, NGINX in prod)
  index.html         → Main page shell
  robot.js           → Core app logic (fetch API calls, layer loading, UI)
  validation.js      → LiveValidation form validation
  layers/            → HTML fragments loaded dynamically (Home, App, Comms)
deploy/
  cgi/               → Bash CGI scripts that run on the Pi (read/write /etc/formfactor/ configs)
  nginx.conf         → NGINX config for the device
  sync.sh            → Deployment script (babel build + rsync)
  config/            → Example device config files
```

## Key Patterns

- **Frontend → Device:** `fetch('/cgi/' + scriptName)` with GET for reads, POST for writes. POST body is `&`-delimited key=value text (Content-Type: text/plain), not JSON.
- **CGI scripts** source config from `/etc/formfactor/*.conf` and return JSON with `{"status":"OK", ...}`.
- **Layer loading:** HTML fragments fetched via `fetch('layers/layerName.html')` and injected into the DOM.
- **Authentication:** NGINX Basic Auth with `.htpasswd`. The dev proxy forwards credentials to the device. Password changes go through `setpasswd.sh` CGI which updates `.htpasswd`.
- **Network config:** Uses NetworkManager (nmcli). `www-data` has sudoers access to run `nmcli`.
- **Network failsafe:** Systemd service checks GPIO 5 (ENTER button) at boot; if held 3s, resets to DHCP.
