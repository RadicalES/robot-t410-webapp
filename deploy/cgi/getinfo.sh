#!/bin/sh
#
# getinfo.sh
# CGI Script to retrieve the device environment data
#
# (C) 2016-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

KERNEL=$(uname -r)
HOST=$(cat /etc/hostname)
DISTRO="RPI "$(cat /etc/issue | tr -cd '[:print:]' | tr -d '\\' | sed 's/ n l\[9;0\]//g')
UPTIME=$(cat /proc/uptime | awk '{ print $1 }')
PISERIAL=$(cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2 | cut -c 9-16 | tr '[:lower:]' '[:upper:]')
IFACE=eth0
SERIAL=1000000000
DATE=1999-01-01
RELEASE=NOT-SET
# cat  /etc/issue | jq -Rs '{issue: .}'

# Manufacturing Information
. /etc/formfactor/maninfo
. /etc/robot-issue

if [ "$REQUEST_METHOD" = "OPTIONS" ]; then
    echo -e "Access-Control-Allow-Origin: *\r\n\r\n"
else

    MAC=$(cat /sys/class/net/${IFACE}/address | tr '[:lower:]' '[:upper:]')

    DEVICEINFO="{
        \"model\":\"ROBOT-T430\",
        \"serialno\":\"$SERIAL ($PISERIAL)\",
        \"mandate\": \"$DATE\",
        \"etherports\": \"1\",
        \"serial232ports\": \"0\",
        \"serial485ports\": \"0\",
        \"usbslaveports\": \"0\",
        \"usbhostports\": \"2\",
        \"wlanports\": \"0\",
        \"uptime\": \"$UPTIME\",
        \"hwrev\": \"1A\",
        \"firmware\":\"$DISTRO ($RELEASE)\",
        \"kernel\":\"$KERNEL\",
        \"macaddress\":\"$MAC\"
    }"

    echo "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
    echo "{\"status\":\"OK\",\"deviceInfo\":$DEVICEINFO}"

fi