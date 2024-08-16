#!/bin/sh
#
# getinfo.sh
# CGI Script to retrieve the device environment data
#
# (C) 2016-2020, Radical Electronic Systems - www.radicalsystems.co.za
# 2020-04-19: Updated for Hiawatha HTTP Server
# Written by Jan Zwiegers, jan@radicalsystems.co.za

KERNEL=$(uname -r)
HOST=$(cat /etc/hostname)
DISTRO=$(cat /etc/issue)
IFACE=eth0
APP="RobotBrowser"

if [ "$REQUEST_METHOD" = "OPTIONS" ]; then
    echo -e "Access-Control-Allow-Origin: *\r\n\r\n"
else

    read MAC </sys/class/net/$IFACE/address

    DEVICEINFO="{
        \"model\":\"ROBOT-T420\",
        \"serialno\":\"10001\",
        \"mandate\": \"2020-01-01\",
        \"etherports\": \"1\",
        \"serial232ports\": \"2\",
        \"serial485ports\": \"0\",
        \"usbslaveports\": \"0\",
        \"usbhostports\": \"1\",
        \"wlanports\": \"1\",
        \"uptime\": \"1000\",
        \"hwrev\": \"1A\",
        \"firmware\":\"$DISTRO\",
        \"kernel\":\"$KERNEL\",
        \"macaddress\":\"$MAC\",
        \"startapp\":\"$APP\"
    }"

    echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
    echo -e "{\"status\":\"OK\",\"deviceInfo\":$DEVICEINFO}"

fi