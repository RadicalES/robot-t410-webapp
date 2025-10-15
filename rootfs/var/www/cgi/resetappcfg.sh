#!/bin/sh
#
# resetappcfg.sh
# CGI Script to reset communications configuration
#
# (C) 2017-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

cp /etc/formfactor/app-orig.conf /etc/formfactor/app.conf

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\"}"

