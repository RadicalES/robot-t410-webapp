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

read MAC </sys/class/net/$IFACE/address
echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"operatingsystem\":\"poky-$HOST\", \"distro\":\"$DISTRO\", \"kernel\":\"$KERNEL\", \"macaddress\":\"$MAC\", \"startapp\":\"$APP\"}"

