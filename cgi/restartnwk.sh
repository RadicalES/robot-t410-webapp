#!/bin/sh
# 
# restartnwk.sh
# CGI Script to restart the network interface
#
# (C) 2016-2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\"}"

/etc/init.d/networking restart >> /dev/null
