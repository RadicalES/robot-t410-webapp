#!/bin/sh
# 
# getethernet.sh
# CGI Script to retrieve the current network setup and return as JSON result
#
# (C) 2016 - 2024, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

# DEVICE COMMANDS
# nmcli -g IP4 dev show wlan0
# nmcli -g GENERAL.STATE dev show wlan0
# nmcli -g AP dev show

DEBUG=ON

CONNECTIONS=$(nmcli -g NAME,TYPE,ACTIVE,STATE,UUID,DEVICE con show)
LANINFO=$(echo $CONNECTIONS | tr ' ' '\n' | grep '802-3-ethernet')
LANNAME=$(echo $LANINFO | awk -F ':' '{print $1}')
LANUUID=$(echo $LANINFO | awk -F ':' '{print $5}')
#LANIF=$(echo $LANINFO | awk -F ':' '{print $6}')
LANIF=eth0


# ETHERNET SECTION
LANMAC=$(cat /sys/class/net/$LANIF/address)
LANDHCP=$(nmcli -g IPV4.METHOD con show $LANNAME)

if [ -n "$LANDHCP" ] && [ $LANDHCP == "auto" ]; then
	LANCFG=$(ifconfig $LANIF | grep 'inet addr')
	LANIP=$(echo $LANCFG | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
	LANGW=$(ip route | grep $LANIF | awk '/default/ { print $3 }')
	LANDNS=$(nmcli -g IP4.DNS dev show $LANIF | cut -d \| -f 1)
	LANMASK=$(echo $LANCFG | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')

else 
	LANCFG=$(nmcli -g ipv4 con show $LANNAME)
	LANIP=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==2 {print $3}')
	LANGW=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==2 {print $4}')
	LANDNS=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==1 {print $3}')
	# LANDNS=$(nmcli -g IPV4.DNS con show $LANNAME)
	LANMASK=$(ifconfig $LANNAME | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')

fi

if [ -n "$DEBUG" ] && [ $DEBUG == "ON" ]; then
	echo "LANINFO: $LANINFO"
	echo "LANIF: $LANIF"
	echo "LANNAME: $LANNAME"
	echo "LANCFG: $LANCFG"
	echo "LANMAC: $LANMAC"
	echo "LANDHCP: $LANDHCP"
	echo "LANIP: $LANIP"
	echo "LANGW: $LANGW"
	echo "LANDNS: $LANDNS"
	echo "LANMASK: $LANMASK"
fi

if [ -n "$LANIP"  ]; then	
	LANSETUP="\"macaddr\":\"$LANMAC\",\"enabled\":\"true\",\"name\":\"eth0\",\"uuid\":\"$LANUUID\",\"ipaddr\":\"$LANIP\",\"gateway\":\"$LANGW\",\"dns\":\"$LANDNS\",\"dhcp\":\"$LANDHCP\""
else
	LANSETUP="\"name\":\"$LANNAME\",\"enabled\":\"false\",\"macaddr\":\"$LANMAC\""
fi



echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\",$LANSETUP,\"dnsip\":\"$GDNS\",\"ntpip\":\"$GNTP\"}"
