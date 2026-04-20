# Project Context

## Architecture
- Vanilla JS single-page app targeting Qt5WebKit (~Safari 6-8 level browser)
- Vite dev server serves frontend from `public/`, proxies `/cgi/*` to device IP in `.env`
- Vite injects `<script>` into HTML files — layer fragments in `public/layers/` need the `rawHtmlFragments` plugin in `vite.config.js` to bypass this
- Dynamic layers are appended hidden (`display:none`) and only shown after data loads
- Admin and Contact layers are inline in index.html (other layers loaded dynamically)

## Branches
- **T430** — standard branch for Robot-T430 (RPi CM4), NGINX, NetworkManager
- **t430-palpi** — T430 with PalPi (Paltrack) service support
- **T420QT** — vanilla JS SPA for Robot-T420 (Qt5WebKit, 800x480 resistive touchscreen)

## Design
- Brand color: orange (`--accent: #e8710a`), logo is orange on transparent
- Header: dark slate (`--nav-bg: #1e293b`) — no CSS filters on logo
- CSS custom properties in `:root` in `site.css`

## Devices
- **T430 test device**: 10.224.40.167, user: robot, pass: t430, NGINX, web root `/var/www/html/`
- **T420 test device**: 10.224.40.178, user: root, pass: temppw, Hiawatha, web root `/var/www/hiawatha/`
- SSH key auth NOT set up — use `sshpass` for all remote commands

## Build & Deploy (T420QT)
- `npm run dev` — Vite dev server on port 3000
- `npm run build` — full build: babel + minify CSS/HTML + version injection → `build/`
- `npm run deploy` — build (if needed) + rsync to device
- Device config in `.env`: DEVICE_HOST, DEVICE_USER, DEVICE_PASS, DEVICE_WEB_ROOT
- See [WORKFLOW.md](WORKFLOW.md) for full details

## Versions
- T420QT: single `VERSION` file is source of truth
- Build script injects `%%VERSION%%` placeholders in robot.js and index.html
- GitHub release tags include branch name: e.g. `v2.0.0-t420qt`, `v2.0.1-t430-palpi`

## Workflow Rules
- NEVER make direct filesystem changes on the device — always edit locally and deploy
- Work from the rootfs repo (`rbtT420_rootfs_all/`) — webapp is a submodule inside it at `webapp/`
- Edit webapp files in `rbtT420_rootfs_all/webapp/`, commit and push from there
- Rootfs repo is the source of truth for system files and CGI scripts
- Webapp repo is the source of truth for web UI files

## Gotchas

### QtWebKit
- No `Symbol.iterator` — NEVER use `for...of` on NodeList/HTMLCollection (use index-based `for` loops)
- No native CSS checkbox sizing — use `-webkit-appearance: none` with custom drawn checkboxes
- RBrowser injects `fetch.js` and `foreach.js` polyfills
- RBrowser debugger: WebSocket on device port 8001

### Babel / Minification
- `sourceType: "script"` in `.babelrc` to avoid strict mode breaking LiveValidation
- Target `safari 9` to compile to ES5
- All globals need explicit `var` declarations (strict mode)
- `this.callback` in global functions becomes undefined — use `callback` directly
- Do NOT use `--minify-js` in html-minifier-terser — adds strict mode to inline scripts

### Vite
- Layer HTML fragments need `rawHtmlFragments` plugin to prevent Vite script injection
- Proxy forwards Basic Auth to device automatically

### CGI Scripts
- Always output HTTP headers before any command that might produce output
- CGI runs as `www-data` — needs sudoers for iw, wpa_cli, systemctl
- Use full paths in CGI: `/usr/bin/sudo`, `/bin/systemctl`, `/usr/sbin/iw`
- POST body is URL-encoded `key=value&key=value` with `Content-Type: text/plain`
- Reset scripts write defaults directly (no -orig.conf files)

### CSS/Layout
- Layer visibility managed by JS `showMenuLayer()` — inline layers need `style="display:none"`
- Never use CSS filters on the logo
- 800x480 portrait = 480px width — use `w3-col s6 m6 l6` to keep 2-column layout

### Deploy
- No SSH key auth — always need `sshpass`
- `rsync` needs `RSYNC_RSH` env var set for sshpass
- Copyright year: 2026
- package-lock.json is gitignored
