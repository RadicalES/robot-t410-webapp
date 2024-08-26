#!/bin/sh
#
# resetcommscfg.sh
# CGI Script to reset application configuration
#
# (C) 2017-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

cp /etc/formfactor/appconfig.orig /etc/formfactor/appconfig
cp /etc/formfactor/wificonfig.orig /etc/formfactor/wificonfig
cp /etc/formfactor/serialconfig.orig /etc/formfactor/serialconfig

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\"}"

