# T420QT Build & Deploy Workflow

## Prerequisites
- Node.js with npm
- `sshpass` installed locally
- Device accessible via SSH

## Environment (.env)
```
DEVICE_IP=http://10.224.40.178    # Vite dev proxy target
DEVICE_USER=root
DEVICE_HOST=10.224.40.178
DEVICE_PASS=temppw
DEVICE_WEB_ROOT=/var/www/hiawatha  # optional, defaults to /var/www/hiawatha
```

## Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start Vite dev server (port 3000), proxies `/cgi/*` to device |
| `npm run build` | Full production build into `build/` |
| `npm run deploy` | Build (if needed) + rsync to device |

## Build Pipeline (`scripts/build.sh`)
1. Clean `build/` directory
2. Babel transpile `robot.js` + `validation.js` to ES5 (compact, no comments)
3. Minify `site.css` with clean-css
4. Minify `index.html` + `layers/*.html` with html-minifier-terser (no `--minify-js`)
5. Copy static assets: `w3.css`, `favicon.png`, `robot.png`

## Deploy Pipeline (`scripts/deploy.sh`)
1. Load `.env` for device credentials
2. Run build if `build/` is missing
3. rsync `build/` to device web root (excludes `cgi/`)

## Important Notes
- **Do NOT use `--minify-js`** in html-minifier-terser — it adds strict mode which breaks inline LiveValidation scripts
- Babel config in `.babelrc`: `sourceType: "script"` (avoids strict mode), target `safari 9` (ES5 for QtWebKit)
- CGI scripts are NOT part of this build — they live in the rootfs repo and are deployed separately
- The `build/` directory is gitignored

## Device Details (T420QT)
- Browser: RBrowser (Qt5WebKit, ~Safari 6-8 level)
- Screen: 800x480 portrait, resistive touchscreen
- Web server: Hiawatha with cgi-wrapper
- Web root: `/var/www/hiawatha/`
- CGI root: `/var/www/hiawatha/cgi/`
- RBrowser debugger: WebSocket on port 8001

## QtWebKit Constraints
- No `Symbol.iterator` — cannot use `for...of` on NodeList/HTMLCollection (use index-based `for` loops)
- No native CSS checkbox sizing — use `-webkit-appearance: none` with custom drawn checkboxes
- RBrowser injects `fetch.js` and `foreach.js` polyfills
- Babel must target safari 9 to compile to ES5
