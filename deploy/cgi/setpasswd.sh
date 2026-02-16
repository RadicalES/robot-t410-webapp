#!/bin/sh
#
# setpasswd.sh
# CGI Script to change the NGINX basic auth password
#
# (C) 2016-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

HTPASSWD_FILE="/etc/nginx/.htpasswd"

echo "Access-Control-Allow-Origin: *"
echo "Content-Type: application/json"
echo ""

# Read POST body
read -r BODY

# Parse fields from URL-encoded body: oldPassword=xxx&newPassword=yyy
OLD_PASS=$(echo "$BODY" | tr '&' '\n' | grep '^oldPassword=' | cut -d'=' -f2-)
NEW_PASS=$(echo "$BODY" | tr '&' '\n' | grep '^newPassword=' | cut -d'=' -f2-)

if [ -z "$OLD_PASS" ] || [ -z "$NEW_PASS" ]; then
    echo '{"status":"ERROR","message":"Missing password fields"}'
    exit 0
fi

# Get the authenticated user from NGINX
AUTH_USER="$REMOTE_USER"
if [ -z "$AUTH_USER" ]; then
    AUTH_USER="admin"
fi

# Verify old password against htpasswd file
STORED_HASH=$(grep "^${AUTH_USER}:" "$HTPASSWD_FILE" | cut -d':' -f2-)
if [ -z "$STORED_HASH" ]; then
    echo '{"status":"ERROR","message":"User not found"}'
    exit 0
fi

# Verify old password using htpasswd in check mode
echo "$OLD_PASS" | htpasswd -iv "$HTPASSWD_FILE" "$AUTH_USER" 2>/dev/null
if [ $? -ne 0 ]; then
    echo '{"status":"ERROR","message":"Current password is incorrect"}'
    exit 0
fi

# Set the new password
echo "$NEW_PASS" | htpasswd -i "$HTPASSWD_FILE" "$AUTH_USER" 2>/dev/null
if [ $? -eq 0 ]; then
    echo '{"status":"OK","message":"Password updated"}'
else
    echo '{"status":"ERROR","message":"Failed to update password"}'
fi
