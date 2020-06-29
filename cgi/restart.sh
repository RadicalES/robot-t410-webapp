#!/bin/sh
# 
# reboot.sh
# Script to reboot the Robot safely.
#
# (C) 2016-2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


echo -e "Content-Type: application/json\r\n\r\n"

if [ "$REQUEST_METHOD" = "POST" ]; then
 #   sudo /sbin/reboot
    echo -e "{\"status\":\"OK\"}"
    sudo /sbin/reboot
else
    echo -e "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi


