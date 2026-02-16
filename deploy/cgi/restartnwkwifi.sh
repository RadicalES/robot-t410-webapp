#!/bin/sh
# 
# restartnwkwifi.sh
# CGI script to restart the WIFI interface
#
# (C) 2016-2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

ifdown wlan0 >> /dev/null
ifup wlan0 >> /dev/null

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\"}"

