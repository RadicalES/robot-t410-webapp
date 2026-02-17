# Robot-T430 Web Application - Installation Guide

(C) 2026 Radical Electronic Systems - www.radicalsystems.co.za

## Prerequisites

The target device (Raspberry Pi CM4) must have:
- NGINX with fcgiwrap installed
- NetworkManager
- apache2-utils (for htpasswd)
- gpiod tools (for network failsafe)

Install prerequisites:
```bash
sudo apt-get install -y nginx fcgiwrap apache2-utils gpiod
```

## Quick Deploy

```bash
tar xzf robot-t430-webapp-v*.tar.gz
cd robot-t430-webapp-v*/
./sync.sh <device-ip> <user>
```

Example:
```bash
./sync.sh 10.224.40.136 robot
```

The sync script will:
1. Deploy web files to `/var/www/html/`
2. Deploy CGI scripts to `/var/www/cgi/`
3. Install NGINX site config and reload NGINX
4. Install the network failsafe service

## First-Time Setup

After the first deployment, create the admin password for the web interface:

```bash
ssh <user>@<device-ip>
sudo htpasswd -c /etc/nginx/.htpasswd admin
sudo chmod 660 /etc/nginx/.htpasswd
sudo chown root:www-data /etc/nginx/.htpasswd
sudo systemctl reload nginx
```

## Release Contents

```
html/                   Web interface files (minified)
cgi/                    CGI bash scripts
nginx.conf              NGINX site configuration
sync.sh                 Deployment script
network-failsafe.sh     Boot-time DHCP reset script
network-failsafe.service  Systemd service for failsafe
www-nmcli               Sudoers file for network management
```

## Network Failsafe

If the device becomes unreachable due to a bad network config, hold the ENTER button (GPIO 5) on the keypad for 3 seconds during boot. This resets the network to DHCP.

Check failsafe logs: `journalctl -t network-failsafe`

## Changing the Password

Use the Administration page in the web interface, or from the command line:
```bash
sudo htpasswd /etc/nginx/.htpasswd admin
```
