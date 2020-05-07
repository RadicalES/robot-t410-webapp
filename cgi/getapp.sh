#!/bin/sh
#
# getapp.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CFGFILE=/etc/formfactor/appconfig

WB_LOAD_URL="http://www.radicalsystems.co.za"
WB_LAYOUT="portrait"

SERWS_SVR_ENABLED=TRUE
SERWS_SVR_SPORT=ttyS2
SERWS_SVR_WPORT=8000
SERWS_SVR_FOREIGN=false
SERWS_SVR_BAUD=115200

TELEM_ENABLED=TRUE
TELEM_PUBTOPIC="robot-t410/events"
TELEM_PORT=1883
TELEM_BROKER="192.168.100.1"

if [ -e $CFGFILE ]; then
  . $CFGFILE
fi

SERWS_SVR_CFG="{\"enabled\":\"$SERWS_SVR_ENABLED\",\"serialport\":\"$SERWS_SVR_SPORT\",\"baudrate\":$SERWS_SVR_BAUD,\"socketport\":$SERWS_SVR_WPORT,\"allowforeign\":\"$SERWS_SVR_FOREIGN\"}"

TELEM_CFG="{\"enabled\":\"$TELEM_ENABLED\",\"port\":$TELEM_PORT,\"pubtopic\":\"$TELEM_PUBTOPIC\",\"broker\":\"$TELEM_BROKER\"}"

BROWSER_CFG="{\"appurl\":\"$WB_LOAD_URL\",\"layout\":\"$WB_LAYOUT\"}"

JSON="\"status\":\"OK\",\"browser\":$BROWSER_CFG,\"serialws\":$SERWS_SVR_CFG,\"telemetry\":$TELEM_CFG";

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
