#!/bin/sh
# 
# reboot.sh
# Script to reboot the Robot safely.
#
# (C) 2016-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"

#   sudo /sbin/reboot
echo -e "{\"status\":\"OK\"}"
sudo /sbin/reboot


