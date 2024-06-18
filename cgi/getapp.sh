#!/bin/sh
#
# getapp.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CFGFILE=/etc/formfactor/appconfig

SERVER_CONFIG_URL="http://www.radicalsystems.co.za"

if [ -e $CFGFILE ]; then
  . $CFGFILE
fi

APP_CFG="\"serverUrl\":\"$SERVER_CONFIG_URL\""

JSON="\"status\":\"OK\",$APP_CFG";

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
