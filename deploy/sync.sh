#!/bin/bash
#
# sync.sh - Deploy Robot-T430 web application to device
#
# Usage:
#   ./sync.sh [device-ip] [user]
#
# Environment variables:
#   DEVICE_USER  - SSH user (default: robot)
#   DEVICE_HOST  - Device IP (default: 10.224.40.136)
#   DEVICE_PASS  - SSH password (uses sshpass if set)
#
# Can be run from the release tarball or the project repo.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

DEVICE_USER="${2:-${DEVICE_USER:-robot}}"
DEVICE_HOST="${1:-${DEVICE_HOST:-10.224.40.136}}"
DEVICE_PASS="${DEVICE_PASS:-}"
REMOTE_WWW="/var/www/html"
REMOTE_CGI="/var/www/cgi"

# Load .env if present (when running from repo)
for ENV_FILE in "$SCRIPT_DIR/../.env" "$SCRIPT_DIR/.env"; do
    if [ -f "$ENV_FILE" ]; then
        export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)
        if [ -n "$DEVICE_IP" ]; then
            DEVICE_HOST="${1:-$(echo "$DEVICE_IP" | sed -E 's|https?://([^:/]+).*|\1|')}"
        fi
        break
    fi
done

# If password is set, use sshpass for all SSH/SCP/rsync
SSH_CMD="ssh"
SCP_CMD="scp"
if [ -n "$DEVICE_PASS" ]; then
    if ! command -v sshpass &>/dev/null; then
        echo "Error: sshpass is required when DEVICE_PASS is set."
        echo "Install with: sudo apt-get install sshpass"
        exit 1
    fi
    SSH_CMD="sshpass -p $DEVICE_PASS ssh -o StrictHostKeyChecking=no"
    SCP_CMD="sshpass -p $DEVICE_PASS scp -o StrictHostKeyChecking=no"
    export RSYNC_RSH="sshpass -p $DEVICE_PASS ssh -o StrictHostKeyChecking=no"
fi

# Determine paths - works from release tarball or repo
if [ -d "$SCRIPT_DIR/html" ]; then
    HTML_DIR="$SCRIPT_DIR/html"
    CGI_DIR="$SCRIPT_DIR/cgi"
    NGINX_CONF="$SCRIPT_DIR/nginx.conf"
    FAILSAFE_SH="$SCRIPT_DIR/network-failsafe.sh"
    FAILSAFE_SVC="$SCRIPT_DIR/network-failsafe.service"
    SUDOERS_FILE="$SCRIPT_DIR/www-nmcli"
else
    echo "No release build found. Run 'npm run release' first."
    exit 1
fi

echo "=== Robot-T430 Deployment ==="
echo "Target: ${DEVICE_USER}@${DEVICE_HOST}"
echo ""

# Install prerequisites if missing
echo "[1/5] Checking prerequisites..."
$SSH_CMD "${DEVICE_USER}@${DEVICE_HOST}" "\
    dpkg -s apache2-utils >/dev/null 2>&1 || \
    (echo 'Installing apache2-utils...' && sudo apt-get update -qq && sudo apt-get install -y -qq apache2-utils)"

# Deploy static files
echo "[2/5] Deploying web files..."
rsync -avz --delete --rsync-path="sudo rsync" \
    "$HTML_DIR/" \
    "${DEVICE_USER}@${DEVICE_HOST}:${REMOTE_WWW}/"

# Deploy CGI scripts
echo "[3/5] Deploying CGI scripts..."
rsync -avz --delete --rsync-path="sudo rsync" --chmod=755 \
    "$CGI_DIR/" \
    "${DEVICE_USER}@${DEVICE_HOST}:${REMOTE_CGI}/"

# Deploy NGINX config
echo "[4/5] Deploying NGINX config..."
$SCP_CMD "$NGINX_CONF" "${DEVICE_USER}@${DEVICE_HOST}:/tmp/robot-t430.conf"
$SSH_CMD "${DEVICE_USER}@${DEVICE_HOST}" "\
    sudo cp /tmp/robot-t430.conf /etc/nginx/sites-available/robot-t430 && \
    sudo ln -sf /etc/nginx/sites-available/robot-t430 /etc/nginx/sites-enabled/robot-t430 && \
    sudo rm -f /etc/nginx/sites-enabled/default && \
    sudo nginx -t && \
    sudo systemctl reload nginx"

# Deploy failsafe service
echo "[5/5] Deploying network failsafe..."
$SCP_CMD "$FAILSAFE_SH" "${DEVICE_USER}@${DEVICE_HOST}:/tmp/network-failsafe.sh"
$SCP_CMD "$FAILSAFE_SVC" "${DEVICE_USER}@${DEVICE_HOST}:/tmp/network-failsafe.service"
$SCP_CMD "$SUDOERS_FILE" "${DEVICE_USER}@${DEVICE_HOST}:/tmp/www-nmcli"
$SSH_CMD "${DEVICE_USER}@${DEVICE_HOST}" "\
    sudo cp /tmp/network-failsafe.sh /usr/local/bin/network-failsafe.sh && \
    sudo chmod +x /usr/local/bin/network-failsafe.sh && \
    sudo cp /tmp/network-failsafe.service /etc/systemd/system/ && \
    sudo systemctl daemon-reload && \
    sudo systemctl enable network-failsafe.service && \
    sudo cp /tmp/www-nmcli /etc/sudoers.d/www-nmcli && \
    sudo chmod 440 /etc/sudoers.d/www-nmcli"

echo ""
echo "=== Deployment complete ==="
echo "Access at http://${DEVICE_HOST}"
echo ""
echo "If this is a first-time install, create the web UI password:"
echo "  $SSH_CMD ${DEVICE_USER}@${DEVICE_HOST} 'sudo htpasswd -c /etc/nginx/.htpasswd robot && sudo chmod 660 /etc/nginx/.htpasswd && sudo chown root:www-data /etc/nginx/.htpasswd && sudo systemctl reload nginx'"
