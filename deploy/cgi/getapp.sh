#!/bin/sh
#
# getapp.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CFGFILE=/etc/robot/app.conf

SERVER_CONFIG_URL="http://www.radicalsystems.co.za"
TRANSACTION_URL=""
API_PROTOCOL='ROBOT-API'
APP_ENGINE='TERMINAL'
SCALE_TYPE='RICHTER'
HOSTNAME=$(cat /etc/hostname)

if [ -e $CFGFILE ]; then
  . $CFGFILE
fi


APP_CFG="{
  \"tagName\":\"$HOSTNAME\",
  \"serverURL\":\"$SERVER_CONFIG_URL\",
  \"transactionURL\":\"$TRANSACTION_URL\",
  \"engines\":\"TERMINAL,FORKLIFT\",
  \"engine\":\"$APP_ENGINE\",
  \"protocols\":\"ROBOT-API,TRANSACT-API,FARSOFT-API\",
  \"protocol\":\"$API_PROTOCOL\",
  \"scales\":\"RICHTER,MASSAMATIC,RINSTRUM\",
  \"scale\":\"$SCALE_TYPE\",
  \"startapps\":\"DESKTOP:Desktop,BROWSER:Robot Browser,CHROME:Chrome Kiosk,ROBOT-APP:Robot App,DEVICE_WEBAPP:Device Web App\",
  \"startapp\":\"$START_APP\"
  }"

JSON="\"status\":\"OK\",\"appConfig\":$APP_CFG";

echo "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo "{$JSON}"
