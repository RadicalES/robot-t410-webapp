#!/bin/bash
set -e

PROJ="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$PROJ/build"
ENV_FILE="$PROJ/.env"

# Load .env
if [ -f "$ENV_FILE" ]; then
	export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

HOST="${DEVICE_HOST:?Set DEVICE_HOST in .env}"
USER="${DEVICE_USER:-root}"
PASS="${DEVICE_PASS:-temppw}"
WEB_ROOT="${DEVICE_WEB_ROOT:-/var/www/hiawatha}"

# Build first if needed
if [ ! -d "$OUT" ] || [ ! -f "$OUT/robot.js" ]; then
	echo "==> Build directory missing, running build first..."
	bash "$PROJ/scripts/build.sh"
fi

echo "==> Deploying to ${USER}@${HOST}:${WEB_ROOT}..."
RSYNC_RSH="sshpass -p $PASS ssh -o StrictHostKeyChecking=no" \
	rsync -av --exclude='cgi' "$OUT/" "${USER}@${HOST}:${WEB_ROOT}/"

echo "==> Deploy complete"
