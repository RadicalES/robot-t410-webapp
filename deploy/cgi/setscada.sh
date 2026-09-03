#!/bin/sh
#
# setscada.sh
# Take this terminal off its SCADA server, or put it back on.
#
#   POST action=disconnect | connect
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
ACTION=$(echo "$BODY" | tr '&' '\n' | grep '^action=' | cut -d= -f2-)

case "$ACTION" in
    disconnect|connect)
        sudo /usr/local/sbin/scada-config "$ACTION" 2>/dev/null \
            || echo '{"status":"FAILED","message":"could not change the connection"}'
        ;;
    *)
        echo '{"status":"FAILED","message":"action must be connect or disconnect"}'
        ;;
esac
