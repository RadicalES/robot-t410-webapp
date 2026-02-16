#!/bin/bash
#
# sync.sh - Deploy web application to Robot-T430 device
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Defaults
DEVICE_USER="${DEVICE_USER:-robot}"
DEVICE_HOST="${DEVICE_HOST:-10.224.40.136}"
REMOTE_WWW="/var/www/html"
REMOTE_CGI="/var/www/cgi"

# Load .env if present
if [ -f "$PROJECT_DIR/.env" ]; then
    export $(grep -v '^#' "$PROJECT_DIR/.env" | grep -v '^$' | xargs)
    if [ -n "$DEVICE_IP" ]; then
        DEVICE_HOST=$(echo "$DEVICE_IP" | sed -E 's|https?://([^:/]+).*|\1|')
    fi
fi

echo "Deploying to ${DEVICE_USER}@${DEVICE_HOST}"

# Build JS with babel
echo "Building JS..."
cd "$PROJECT_DIR"
npx babel public/robot.js public/validation.js --out-dir build --compact=true --no-comments

# Copy static assets to build/
echo "Copying static assets..."
cp public/index.html build/
cp -r public/layers build/
cp public/favicon.png build/
cp public/site.css build/
cp public/robot.png build/
cp public/w3.css build/

# Deploy static files
echo "Deploying static files..."
rsync -avz --rsync-path="sudo rsync" \
    build/ \
    "${DEVICE_USER}@${DEVICE_HOST}:${REMOTE_WWW}/"

# Deploy CGI scripts
echo "Deploying CGI scripts..."
rsync -avz --rsync-path="sudo rsync" --chmod=755 \
    deploy/cgi/ \
    "${DEVICE_USER}@${DEVICE_HOST}:${REMOTE_CGI}/"

echo "Done. Access at http://${DEVICE_HOST}"
