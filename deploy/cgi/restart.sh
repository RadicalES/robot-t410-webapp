#!/bin/sh
# 
# reboot.sh
# Script to reboot the Robot safely.
#
# (C) 2016-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

echo "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"

#   sudo /sbin/reboot
echo "{\"status\":\"OK\"}"
sudo /sbin/reboot


