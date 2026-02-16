#!/bin/bash
#
# setup-auth.sh - Initialize NGINX Basic Auth on the device
# Run once after first deployment
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

DEVICE_USER="${DEVICE_USER:-robot}"
DEVICE_HOST="${DEVICE_HOST:-10.224.40.136}"

# Load .env if present
if [ -f "$PROJECT_DIR/.env" ]; then
    export $(grep -v '^#' "$PROJECT_DIR/.env" | grep -v '^$' | xargs)
    if [ -n "$DEVICE_IP" ]; then
        DEVICE_HOST=$(echo "$DEVICE_IP" | sed -E 's|https?://([^:/]+).*|\1|')
    fi
fi

echo "Setting up Basic Auth on ${DEVICE_USER}@${DEVICE_HOST}"
echo ""
echo "This will create the admin user for the web interface."
echo "You will be prompted for the password."
echo ""

ssh "${DEVICE_USER}@${DEVICE_HOST}" "sudo apt-get install -y apache2-utils && \
    sudo htpasswd -c /etc/nginx/.htpasswd admin && \
    sudo chmod 660 /etc/nginx/.htpasswd && \
    sudo chown root:www-data /etc/nginx/.htpasswd && \
    sudo nginx -t && \
    sudo systemctl reload nginx"

echo ""
echo "Done. The web interface now requires login as 'admin'."
