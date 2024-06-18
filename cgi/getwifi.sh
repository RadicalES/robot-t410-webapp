#!/bin/sh
# 
# getnwkcfg.sh
# CGI Script to retrieve the current network setup and return as JSON result
#
# (C) 2016 - 2024, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

# DEVICE COMMANDS
# nmcli -g IP4 dev show wlan0
# nmcli -g GENERAL.STATE dev show wlan0
# nmcli -g AP dev show

DEBUG=OFF

CONNECTIONS=$(nmcli -g NAME,TYPE,ACTIVE,STATE,UUID,DEVICE con show)
WIFIINFO=$(echo $CONNECTIONS | tr ' ' '\n' | grep '802-11-wireless')
WIFINAME=$(echo $WIFIINFO | awk -F ':' '{print $1}')
WIFIUUID=$(echo $WIFIINFO | awk -F ':' '{print $5}')
WIFIIF=$(echo $WIFIINFO | awk -F ':' '{print $6}')

# WLAN SECTION
WIFIMAC=$(cat /sys/class/net/$WIFIIF/address)
WIFIDHCP=$(nmcli -g IPV4.METHOD con show $WIFINAME)

if [ -n "$WIFIDHCP" ] && [ $WIFIDHCP == "auto" ]; then
	WIFICFG=$(ifconfig $WIFIIF | grep 'inet addr')
	WIFIIP=$(echo $WIFICFG | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
	WIFIGW=$(ip route | grep $WIFIIF | awk '/default/ { print $3 }')
	WIFIDNS=$(nmcli -g IP4.DNS dev show $WIFIIF)
	WIFIMASK=$(echo $WIFICFG | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')

else 
	WIFICFG=$(nmcli -g ipv4 con show $WIFINAME)
	WIFIIP=$(echo $WIFICFG | sed 's/::/\n/g' | awk -F ':' 'NR==2 {print $3}')
	WIFIGW=$(echo $WIFICFG | sed 's/::/\n/g' | awk -F ':' 'NR==2 {print $4}')
	WIFIDNS=$(echo $WIFICFG | sed 's/::/\n/g' | awk -F ':' 'NR==1 {print $3}')
	# WIFIDNS=$(nmcli -g IPV4.DNS con show $WIFINAME)
	WIFIMASK=$(ifconfig $WIFINAME | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')

fi

if [ -n "$DEBUG" ] && [ $DEBUG == "on" ]; then
	echo "WIFIINFO: $WIFIINFO"
	echo "WIFINAME: $WIFINAME"
	echo "WIFIIF: $WIFIIF"
	echo "WIFICFG: $WIFICFG"
	echo "WIFIMAC: $WIFIMAC"
	echo "WIFIDHCP: $WIFIDHCP"
	echo "WIFIIP: $WIFIIP"
	echo "WIFIGW: $WIFIGW"
	echo "WIFIDNS: $WIFIDNS"
	echo "WIFIMASK: $WIFIMASK"
fi

if [ -n "$WIFIIP"  ]; then	
	WIFISETUP="\"macAddress\":\"$WIFIMAC\",\"enabled\":\"true\",\"name\":\"$WIFIIF\",\"uuid\":\"$WIFIUUID\",\"ssid\":\"$WIFINAME\",\"ipAddress\":\"$WIFIIP\",\"gateway\":\"$WIFIGW\",\"dns\":\"$WIFIDNS\",\"dhcp\":\"$WIFIDHCP\""
else
	WIFISETUP="\"name\":\"$WIFINAME\",\"enabled\":\"false\",\"macAddress\":\"$WIFIMAC\""
fi

WIFIAP="{\"SSID\":\"$WIFINAME\"}"

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\",$WIFISETUP,\"wifiap\":$WIFIAP,\"dnsip\":\"$GDNS\",\"ntpip\":\"$GNTP\"}"
