#!/bin/sh
#
# getapp.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CFGFILE=/etc/formfactor/appconfig

SERVER_CONFIG_URL="http://www.radicalsystems.co.za"
TAG_NAME="NOT SET"

if [ -e $CFGFILE ]; then
  . $CFGFILE
fi



APP_CFG="{
  \"tagName\":\"$TAG_NAME\",
  \"serverURL\":\"$SERVER_CONFIG_URL\",
  \"engines\":\"TERMINAL,FORKLIFT\",
  \"enabled\":\"FORKLIFT\",
  \"protocols\":\"ROBOT-API,FARSOFT-API\",
  \"protocol\":\"FARSOFT-API\",
  \"scales\":\"RICHTER\",
  \"scale\":\"RICHTER\"
  
  }"

JSON="\"status\":\"OK\",\"appConfig\":$APP_CFG";

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
