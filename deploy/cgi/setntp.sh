#!/bin/sh
#
# setntp.sh
# CGI script to set the system time server.
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za

echo "Access-Control-Allow-Origin: *"
echo "Content-Type: application/json"
echo ""

if [ "$REQUEST_METHOD" != "POST" ]; then
    echo '{"status":"ERROR","message":"POST required"}'
    exit 0
fi

read -r BODY

NTP=$(echo "$BODY" | tr '&' '\n' | grep '^ntp=' | cut -d'=' -f2- | sed 's/+/ /g;s/%20/ /g')

if RESULT=$(/usr/bin/sudo -n /usr/local/sbin/ntp-config "$NTP" 2>&1); then
    echo '{"status":"OK","message":"Time server updated"}'
else
    echo "{\"status\":\"ERROR\",\"message\":\"$(echo "$RESULT" | tr -d '"' | tr '\n' ' ')\"}"
fi
