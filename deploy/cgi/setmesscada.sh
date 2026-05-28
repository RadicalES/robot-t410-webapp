#!/bin/sh
#
# setmesscada.sh
# CGI Script to apply the web-editable MesScada settings (Local IP, Server IP,
# Station number). Delegates the file edits to a validated root helper.
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

get_param() {
    echo "$BODY" | tr '&' '\n' | grep "^${1}=" | cut -d'=' -f2- | sed 's/+/ /g;s/%2E/./g;s/%2e/./g'
}

LOCAL=$(get_param "localIp")
SERVER=$(get_param "serverIp")
STATION=$(get_param "station")

if [ -z "$LOCAL" ] || [ -z "$SERVER" ] || [ -z "$STATION" ]; then
    echo '{"status":"ERROR","message":"localIp, serverIp and station are required"}'
    exit 0
fi

RESULT=$(sudo /usr/local/bin/messcada-config-apply.sh "$LOCAL" "$SERVER" "$STATION" 2>&1)
if [ $? -eq 0 ]; then
    echo '{"status":"OK","message":"MesScada settings saved. Reboot to apply."}'
else
    echo "{\"status\":\"ERROR\",\"message\":\"$RESULT\"}"
fi
