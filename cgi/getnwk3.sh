#!/bin/sh
# 
# getnwkcfg.sh
# CGI Script to retrieve the current network setup and return as JSON result
#
# (C) 2016 - 2024, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

# All active connections
# CONNECTIONS=$(nmcli -t -f name connection show --active)
# gives eth0, SSID of WLAN

# awk 'NR==2 {print $2}'
# sed -n '2 p'

CONNECTIONS=$(nmcli -g NAME,TYPE,ACTIVE,STATE,UUID con show)
LANINFO=$(echo $CONNECTIONS | tr ' ' '\n' | grep '802-3-ethernet')
LANNAME=$(echo $LANINFO | awk -F ':' '{print $1}')
LANUUID=$(echo $LANINFO | awk -F ':' '{print $5}')

WIFIINFO=$(echo $CONNECTIONS | tr ' ' '\n' | grep '802-11-wireless')
WIFINAME=$(echo $WIFIINFO | awk -F ':' '{print $1}')
WIFIUUID=$(echo $WIFIINFO | awk -F ':' '{print $5}')


# echo "WIFIINFO: $WIFINAME"

# IN="bla@some.com;john@home.com"
# arrIN=(${IN//;/ })
# echo ${arrIN[1]}                  # Output: john@home.com

# replace :: with \n - sed 's/::/\n/g'
# get a second line - sed -n '2p' or awk 'NR==2'

LANIFDEV=eth0
LANMAC=$(cat /sys/class/net/eth0/address)
LANCFG=$(nmcli -g ipv4 con show $LANNAME)
LANDHCP=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==1 {print $2}')
LANIP=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==2 {print $3}')
LANGW=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==2 {print $4}')
LANDNS=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==1 {print $3}')

#echo "Connections: $CONNECTIONS"

echo "LANINFO: $LANINFO"
echo "LANINFO: $LANNAME"
echo "LANCFG: $LANCFG"
echo "LANMAC: $LANMAC"
echo "LANDHCP: $LANDHCP"
echo "LANIP: $LANIP"
echo "LANGW: $LANGW"
echo "LANDNS: $LANDNS"

if [ -n "$LANIP"  ]; then

	if [ -n "$LANDHCP" ] && [ $LANDHCP == "auto" ]; then

		# DHCP address
		IFDATA=$(ifconfig $LANIFDEV | grep 'inet addr')
		if [ -z "$IFDATA" ]; then
			LANCFG="{\"name\":\"$LANIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$LANMAC\",\"ipAddress\":\"0.0.0.0\",\"netmask\":\"0.0.0.0\",\"gateway\":\"0.0.0.0\",\"dns\":\"0.0.0.0\",\"dhcp\":\"TRUE\"}"
		else
			IFIP=$(echo $IFDATA | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
			IFDNS=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }' | sed -n -e 'H;${x;s/\n/,/g;s/^,//;p;}')
			IFMASK=$(echo $IFDATA | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')
			IPGW=$(ip route | grep eth0 | awk '/default/ { print $3 }')
			LANCFG="{\"name\":\"$LANIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$LANMAC\",\"ipAddress\":\"$LANIP\",\"netmask\":\"$IFMASK\",\"gateway\":\"$LANGW\",\"dns\":\"$LANDNS\",\"dhcp\":\"TRUE\"}"
		fi
	
	else
		# Static address
		LANCFG="{\"macAddress\":\"$LANMAC\",\"status\":\"ENABLED\",\"name\":\"$LANIFDEV\",\"ipAddress\":\"$LANIP\",\"gateway\":\"$LANGW\",\"dns\":\"$LANDNS\",\"dhcp\":\"FALSE\"}"
	fi
	
else
	# not configured
	LANCFG="{\"name\":\"$LANIFDEV\",\"status\":\"DISABLED\",\"macAddress\":\"$LANMAC\"}"
fi


if [ -n "$WIFICHECK"  ]; then

	if [ -n "$WIFIDHCP" ] && [ $WIFIDHCP == "auto" ]; then
		WIFICFG="{\"name\":\"$WIFICON\",\"status\":\"ENABLED\",\"macAddress\":\"$WIFIMAC\",\"ipAddress\":\"$WIFIIP\",\"netmask\":\"$WIFIMASK\",\"gateway\":\"$WIFIGW\",\"dns\":\"$WIFIDNS\",\"dhcp\":\"TRUE\"}"
	else 
		echo "Wifi is MANUAL"
	fi

fi

WIFIAP="{\"SSID\":\"$WIFINAME\"}"

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\",\"wired\":$LANCFG,\"wifi\":$WIFICFG,\"wifiap\":$WIFIAP,\"dnsip\":\"$GDNS\",\"ntpip\":\"$GNTP\"}"
