# Robot-T430 Web Application - Installation Guide

(C) 2026 Radical Electronic Systems - www.radicalsystems.co.za

## Prerequisites

The target device (Robot-T430) must have:
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

## Batch Deploy (Multiple Devices)

To deploy to multiple devices at once, create a text file with one IP per line:

```
# devices.txt
10.224.40.1
10.224.40.2
10.224.41.50
192.168.1.100
```

Then run:
```bash
DEVICE_PASS=t430 ./batch-deploy.sh devices.txt 10
```

The second argument is the number of parallel deployments (default: 5).

Each device gets its own log file in `deploy-logs/`. A summary report is generated at the end:

```
deploy-logs/
  report-20260217-091603.txt       Summary report
  20260217-091603_10.224.40.1.log  Per-device log
  20260217-091603_10.224.40.2.log
  ...
```

Environment variables:
- `DEVICE_USER` — SSH user (default: robot)
- `DEVICE_PASS` — SSH password (required for sshpass)

## Release Contents

```
html/                   Web interface files (minified)
cgi/                    CGI bash scripts
nginx.conf              NGINX site configuration
sync.sh                 Single device deployment script
batch-deploy.sh         Multi-device batch deployment script
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
