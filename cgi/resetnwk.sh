#!/bin/sh
# 
# resetnwk.sh
# CGI Script to reset the network to default settings.
#
# (C) 2016-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

IFCFGFILELAN=/etc/systemd/network/eth0.network
IFCFGFILELANTEMP=/etc/systemd/network/eth0.network.default

IFCFGFILEWIFI=/etc/systemd/network/wlan0.network
IFCFGFILEWIFITEMP=/etc/systemd/network/wlan0.network.default

cp $IFCFGFILELANTEMP $IFCFGFILELAN
cp $IFCFGFILEWIFI $IFCFGFILEWIFITEMP

echo "# switch AP mode" > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\"}"

