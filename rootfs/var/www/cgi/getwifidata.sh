#!/bin/sh
# 
# getnwkcfg.sh
# CGI Script to retrieve the current network setup and return as JSON result
#
# (C) 2016 - 2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

WIFIIFDEV=wlan0
WIFIMAC=$(cat /sys/class/net/wlan0/address)
RES=$?

FREQ="0"
LQ="0"
SL="0"
AP="Not-Associated"

WIFIDAT=$(iwconfig wlan0)
ESSID=$(grep ESSID <<< $WIFIDAT)
ESSID=${ESSID#*ESSID:}
# remove white space at the end
ESSID=${ESSID//[[:space:]]}

if [ "$ESSID" != "off/any" ]; then
    ESSID=$(grep ESSID <<< $WIFIDAT)
    ESSID=${ESSID#*ESSID:\"}
    ESSID=${ESSID%\"*}
    FREQ=$(grep Frequency <<< $WIFIDAT)
    FREQ=${FREQ#*Frequency:}
    FREQ=${FREQ% GHz*}
    LQ=$(grep Link <<< $WIFIDAT)
    LQ=${LQ#*Link Quality=}
    LQ=${LQ%  Signal*}
    SL=$(grep Signal <<< $WIFIDAT)
    SL=${SL#*Signal level=}
    SL=${SL% dBm*}
    AP=$(grep Access <<< $WIFIDAT)
    AP=${AP#*Access Point: }
    # AP=${AP%%+([[:space:]])}
    # Remove all whitespace
    AP=${AP//[[:space:]]}
else
    ESSID="Not connected"
fi

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\",\"ESSID\":\"$ESSID\",\"APMAC\":\"$AP\",\"frequency\":\"$FREQ GHz\",\"linkquality\":\"$LQ\",\"signallevel\":\"$SL dBm\"}"
