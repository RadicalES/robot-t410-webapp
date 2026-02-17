# Robot-T430 Development Workflow

## Development

### Local Frontend Development

```bash
npm run dev
```

Opens http://localhost:3000. Edit files in `public/` and see changes instantly. All `/cgi/*` requests are proxied to the device configured in `.env`.

### Configure Target Device

Edit `.env`:
```
DEVICE_IP=http://10.224.40.136
DEVICE_USER=robot
DEVICE_HOST=10.224.40.136
DEVICE_PASS=t430
```

## Building a Release

```bash
npm run release
```

This creates `dist/robot-t430-webapp-vX.X.X/` and a `.tar.gz` with:
- Minified JS (Babel), CSS (clean-css), HTML (html-minifier-terser)
- CGI scripts (chmod 755)
- NGINX config, sync script, failsafe service, sudoers file, README

## Deploying to Device

### From Release Folder

```bash
cd dist/robot-t430-webapp-v2.0.0
DEVICE_PASS=t430 ./sync.sh 10.224.40.136 robot
```

### From Tarball

```bash
tar xzf robot-t430-webapp-v2.0.0.tar.gz
cd robot-t430-webapp-v2.0.0
DEVICE_PASS=t430 ./sync.sh 10.224.40.136 robot
```

The sync script deploys:
1. Web files to `/var/www/html/`
2. CGI scripts to `/var/www/cgi/`
3. NGINX site config (reloads NGINX)
4. Network failsafe service
5. Sudoers file for www-data nmcli access

### First-Time Device Setup

After first deployment, create the web UI password:

```bash
sshpass -p t430 ssh robot@10.224.40.136 \
  'sudo apt-get install -y apache2-utils && \
   sudo htpasswd -c /etc/nginx/.htpasswd robot && \
   sudo chmod 660 /etc/nginx/.htpasswd && \
   sudo chown root:www-data /etc/nginx/.htpasswd && \
   sudo systemctl reload nginx'
```

## Tagging a Release

```bash
# Update version in package.json and public/index.html
# Commit changes
git add -A && git commit -m "Bump to vX.X.X"

# Tag and push
git tag -a vX.X.X -m "vX.X.X - description"
git push && git push --tags

# Build release tarball
npm run release

# Create GitHub release with tarball
gh release create vX.X.X dist/robot-t430-webapp-vX.X.X.tar.gz \
  --title "vX.X.X" \
  --notes "Release notes here"
```

### Updating an Existing Tag

```bash
git tag -d vX.X.X
git push origin :refs/tags/vX.X.X
git tag -a vX.X.X -m "vX.X.X - description"
git push --tags

# Update GitHub release
gh release delete vX.X.X --yes
npm run release
gh release create vX.X.X dist/robot-t430-webapp-vX.X.X.tar.gz \
  --title "vX.X.X" --notes "Release notes"
```

## Quick Test Cycle

During development, to quickly test changes on the device:

```bash
npm run release && cd dist/robot-t430-webapp-v* && DEVICE_PASS=t430 ./sync.sh 10.224.40.136 robot
```

## Network Failsafe

If the device becomes unreachable after a bad network config change, hold the **ENTER button** (GPIO 5) on the keypad for 3 seconds during boot. This resets the network to DHCP.

Check logs: `journalctl -t network-failsafe`
