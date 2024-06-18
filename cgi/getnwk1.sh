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

CONNECTIONS=$(nmcli -g NAME,TYPE,ACTIVE,STATE,UUID con show)

# IN="bla@some.com;john@home.com"
# arrIN=(${IN//;/ })
# echo ${arrIN[1]}                  # Output: john@home.com

LANIFDEV=eth0
LANMAC=$(cat /sys/class/net/eth0/address)
LANCFG=$(nmcli con show eth0)
LANDHCP=$($LANCFG | grep ipv4.method | awk '{print $2}')
LANIP=$($LANCFG | grep ipv4.addresses | awk '{print $2}')
LANGW=$($LANCFG| grep ipv4.gateway | awk '{print $2}')
LANDNS=$($LANCFG | grep 'ipv4.dns:' | awk '{print $2}')

echo "Connections: $CONNECTIONS"

# echo "LANMAC: $LANMAC"
# echo "LANDHCP: $LANDHCP"
# echo "LANIP: $LANIP"
# echo "LANGW: $LANGW"
# echo "LANDNS: $LANDNS"

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

WIFIIFDEV=wlan0
WIFICON=$(nmcli con show --active)
#WIFICON=$(nmcli con show --active | grep wifi | awk '{print $4}')
WIFISSID=$($WIFICON | grep wifi | awk '{print $1}')
WIFIDHCP=$(nmcli con show $WIFISSID | grep ipv4.method | awk '{print $2}')
WIFIDEV=$(nmcli dev show wlan0)
WIFIMAC=$($WIFIDEV | grep GENERAL.HWADDR | awk '{print $2}')
WIFIIP=$($WIFIDEV | grep IP4.ADDRESS | awk '{print $2}')
WIFIGW=$($WIFIDEV | grep IP4.GATEWAY | awk '{print $2}')
WIFIDNS=$($WIFIDEV | grep IP4.DNS | awk '{print $2}')
#WIFICHECK=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d\' -f2)
WIFIMASK="255.255.255.0"

echo "WIFICON: $WIFICON"
echo "WIFISSID: $WIFISSID"
echo "WIFIMAC: $WIFIMAC"
echo "WIFIIP: $WIFIDHCP"
echo "WIFIIP: $WIFIIP"
echo "WIFIGW: $WIFIGW"
echo "WIFIDNS: $WIFIDNS"

if [ -n "$WIFICHECK"  ]; then

	if [ -n "$WIFIDHCP" ] && [ $WIFIDHCP == "auto" ]; then
		WIFICFG="{\"name\":\"$WIFICON\",\"status\":\"ENABLED\",\"macAddress\":\"$WIFIMAC\",\"ipAddress\":\"$WIFIIP\",\"netmask\":\"$WIFIMASK\",\"gateway\":\"$WIFIGW\",\"dns\":\"$WIFIDNS\",\"dhcp\":\"TRUE\"}"
	else 
		echo "Wifi is MANUAL"
	fi

fi

WIFIAP="{\"SSID\":\"$WIFISSID\"}"

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\",\"wired\":$LANCFG,\"wifi\":$WIFICFG,\"wifiap\":$WIFIAP,\"dnsip\":\"$GDNS\",\"ntpip\":\"$GNTP\"}"
