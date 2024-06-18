#!/bin/sh
#
# getapp.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CFGFILE=/etc/formfactor/appconfig

TELEM_ENABLED="true"
TELEM_PUBTOPIC="robot-t410/events"
TELEM_PORT=1883
TELEM_BROKER="192.168.100.1"
TELEM_USER="robot"
TELEM_PASSWD="t410"

if [ -e $CFGFILE ]; then
  . $CFGFILE
fi

TELEM_CFG="\"enabled\":\"$TELEM_ENABLED\",\"port\":$TELEM_PORT,\"pubtopic\":\"$TELEM_PUBTOPIC\",\"broker\":\"$TELEM_BROKER\",\"username\":\"$TELEM_USER\",\"password\":\"$TELEM_PASSWD\""


JSON="\"status\":\"OK\",$TELEM_CFG";

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
