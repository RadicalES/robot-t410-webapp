#!/bin/bash
#
# sync.sh - Deploy Robot-T430 web application to device
#
# Usage:
#   ./sync.sh [device-ip] [user]
#
# Can be run from the release tarball or the project repo.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

DEVICE_USER="${2:-${DEVICE_USER:-robot}}"
DEVICE_HOST="${1:-${DEVICE_HOST:-10.224.40.136}}"
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

# Determine paths - works from release tarball or repo
if [ -d "$SCRIPT_DIR/html" ]; then
    # Running from release folder
    HTML_DIR="$SCRIPT_DIR/html"
    CGI_DIR="$SCRIPT_DIR/cgi"
    NGINX_CONF="$SCRIPT_DIR/nginx.conf"
    FAILSAFE_SH="$SCRIPT_DIR/network-failsafe.sh"
    FAILSAFE_SVC="$SCRIPT_DIR/network-failsafe.service"
    SUDOERS_FILE="$SCRIPT_DIR/www-nmcli"
else
    # Running from repo deploy/ directory
    echo "No release build found. Run 'npm run release' first."
    exit 1
fi

echo "=== Robot-T430 Deployment ==="
echo "Target: ${DEVICE_USER}@${DEVICE_HOST}"
echo ""

# Deploy static files
echo "[1/4] Deploying web files..."
rsync -avz --delete --rsync-path="sudo rsync" \
    "$HTML_DIR/" \
    "${DEVICE_USER}@${DEVICE_HOST}:${REMOTE_WWW}/"

# Deploy CGI scripts
echo "[2/4] Deploying CGI scripts..."
rsync -avz --delete --rsync-path="sudo rsync" --chmod=755 \
    "$CGI_DIR/" \
    "${DEVICE_USER}@${DEVICE_HOST}:${REMOTE_CGI}/"

# Deploy NGINX config
echo "[3/4] Deploying NGINX config..."
scp "$NGINX_CONF" "${DEVICE_USER}@${DEVICE_HOST}:/tmp/robot-t430.conf"
ssh "${DEVICE_USER}@${DEVICE_HOST}" "\
    sudo cp /tmp/robot-t430.conf /etc/nginx/sites-available/robot-t430 && \
    sudo ln -sf /etc/nginx/sites-available/robot-t430 /etc/nginx/sites-enabled/robot-t430 && \
    sudo rm -f /etc/nginx/sites-enabled/default && \
    sudo nginx -t && \
    sudo systemctl reload nginx"

# Deploy failsafe service
echo "[4/4] Deploying network failsafe..."
scp "$FAILSAFE_SH" "${DEVICE_USER}@${DEVICE_HOST}:/tmp/network-failsafe.sh"
scp "$FAILSAFE_SVC" "${DEVICE_USER}@${DEVICE_HOST}:/tmp/network-failsafe.service"
scp "$SUDOERS_FILE" "${DEVICE_USER}@${DEVICE_HOST}:/tmp/www-nmcli"
ssh "${DEVICE_USER}@${DEVICE_HOST}" "\
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
echo "If this is a first-time install, run:"
echo "  ssh ${DEVICE_USER}@${DEVICE_HOST} 'sudo apt-get install -y apache2-utils && sudo htpasswd -c /etc/nginx/.htpasswd admin'"
