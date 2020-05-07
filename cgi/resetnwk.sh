#!/bin/sh
# 
# resetnwk.sh
# CGI Script to reset the network to default settings.
#
# (C) 2016-2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

IFCFGFILE=/etc/network/interfaces
IFCFGFILETEMP=/etc/network/interfaces.default

cp $IFCFGFILETEMP $IFCFGFILE

echo "# switch AP mode" > /etc/wpa_supplicant.conf

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\"}"

