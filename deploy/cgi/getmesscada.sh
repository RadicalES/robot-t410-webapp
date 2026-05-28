#!/bin/sh
#
# getmesscada.sh
# CGI Script to read the web-editable MesScada settings from messcada.xml
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za

MX=/home/nspi/nosoft/messcada/config/messcada.xml

echo "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"

if [ ! -f "$MX" ]; then
    echo '{"status":"FAILED","message":"MesScada is not installed on this device"}'
    exit 0
fi

LOCAL=$(grep -oE 'IPData Local="[0-9.]+"' "$MX" | head -1 | grep -oE '[0-9.]+')
SERVER=$(grep -oE 'Server="[0-9.]+"' "$MX" | head -1 | grep -oE '[0-9.]+')
STATION=$(grep -oE 'PRN-[0-9]+' "$MX" | head -1 | grep -oE '[0-9]+$')

echo "{\"status\":\"OK\",\"messcadaConfig\":{\"localIp\":\"$LOCAL\",\"serverIp\":\"$SERVER\",\"station\":\"$STATION\"}}"
