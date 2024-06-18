#!/bin/sh
#
# getapp.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CFGFILE=/etc/formfactor/telemconfig

ENABLED="true"
PUBTOPIC="robot-t410/events"
PORT=1883
BROKER="192.168.100.1"
USER="robot"
PASSWD="t410"

if [ -e $CFGFILE ]; then
  . $CFGFILE
fi

CONFIG="\"enabled\":\"$ENABLED\",\"port\":$PORT,\"pubtopic\":\"$PUBTOPIC\",\"broker\":\"$BROKER\",\"username\":\"$USER\",\"password\":\"$PASSWD\""


JSON="\"status\":\"OK\",$CONFIG";

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
