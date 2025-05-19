#!/bin/sh
#
# getapp.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CFGFILE=/etc/formfactor/appconfig

SERVER_CONFIG_URL="http://www.radicalsystems.co.za"
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
  \"engines\":\"TERMINAL,FORKLIFT\",
  \"engine\":\"$APP_ENGINE\",
  \"protocols\":\"ROBOT-API,FARSOFT-API\",
  \"protocol\":\"$API_PROTOCOL\",
  \"scales\":\"RICHTER\",
  \"scale\":\"$SCALE_TYPE\",
  \"startapps\":\"DESKTOP,BROWSER\",
  \"startapp\":\"$START_APP\"
  
  }"

JSON="\"status\":\"OK\",\"appConfig\":$APP_CFG";

echo "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo "{$JSON}"
