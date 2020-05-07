#!/bin/sh
# 
# getnwkcfg.sh
# CGI Script to retrieve the current network setup and return as JSON result
#
# (C) 2016 - 2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

IFACECFGFILE=/etc/network/interfaces
DNSCFGFILE=/etc/resolve.conf

GDNS=$(cat /etc/network/resolv.static.conf |grep -i '^nameserver'|head -n1|cut -d ' ' -f2)
GNTP=$(cat /etc/ntp.conf |grep -i '^server'|head -n1|cut -d ' ' -f2)

LANIFDEV=eth0
LANMAC=$(cat /sys/class/net/eth0/address)
LANIFCFG=$(awk -f readInterfaces.awk $IFACECFGFILE device=$LANIFDEV)
RES=$?
if [ -z "$LANMAC" ]; then
	# network interface not available
	LANIFCFG="{\"name\":\"$LANIFCFG\",\"status\":\"NOTAVAIL\",\"macAddress\":\"Not installed\"}"
else
	if [ $RES -eq 0 ]; then
		# Static address
		LANCFG="{\"macAddress\":\"$LANMAC\",\"status\":\"ENABLED\",$LANIFCFG}"
	elif [ $RES -eq 1 ]; then
		# DHCP address
		IFDATA=$(ifconfig $LANIFDEV | grep 'inet addr')
		if [ -z "$IFDATA" ]; then
			LANCFG="{\"name\":\"$LANIFDEV\",status=\"ENABLED\",\"macAddress\":\"$LANMAC\",\"ipAddress\":\"0.0.0.0\",\"netmask\":\"0.0.0.0\",\"gateway\":\"0.0.0.0\",\"dhcp\":\"TRUE\"}"
		else
			IFIP=$(echo $IFDATA | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
			IFMASK=$(echo $IFDATA | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')
			IPGW=$(ip route | awk '/default/ { print $3 }')
			LANCFG="{\"name\":\"$LANIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$LANMAC\",\"ipAddress\":\"$IFIP\",\"netmask\":\"$IFMASK\",\"gateway\":\"$IPGW\",\"dhcp\":\"TRUE\"}"
		fi
	else
		# not configured
		LANCFG="{{\"name\":\"$LANIFCFG\",\"status\":\"DISABLED\",\"macAddress\":\"not configured\"}}"
	fi
fi

WIFIIFDEV=wlan0
WIFIMAC=$(cat /sys/class/net/wlan0/address)
WIFIIFCFG=$(awk -f readInterfaces.awk $IFACECFGFILE device=$WIFIIFDEV)
RES=$?

if [ -z "$WIFIMAC" ]; then
	# network interface not available
	WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"NOTAVAIL\",\"macAddress\":\"not installed\"}"
else
	if [ $RES -eq 0 ]; then
		WIFICFG="{\"macAddress\":\"$WIFIMAC\",\"status\":\"ENABLED\",$WIFIIFCFG}"
	elif [ $RES -eq 1 ]; then
		IFDATA=$(ifconfig $WIFIIFDEV | grep 'inet addr')
		if [ -z "$IFDATA" ]; then
			WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$WIFIMAC\",\"ipAddress\":\"0.0.0.0\",\"netmask\":\"0.0.0.0\",\"gateway\":\"0.0.0.0\",\"dhcp\":\"TRUE\",\"dns\":\"0.0.0.0\"}"
		else
			IFIP=$(echo $IFDATA | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
			IFMASK=$(echo $IFDATA | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')
			IPGW=$(ip route | awk '/default/ { print $3 }')
			WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$WIFIMAC\",\"ipAddress\":\"$IFIP\",\"netmask\":\"$IFMASK\",\"gateway\":\"$IPGW\",\"dhcp\":\"TRUE\"}"
		fi
	else
		WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"DISABLED\",\"macAddress\":\"Not configured\"}"
	fi	
fi

WIFISSID=$(cat /etc/wpa_supplicant.conf | grep ssid)
WIFIPASSW=$(cat /etc/wpa_supplicant.conf | grep "#psk")

WIFISSID=${WIFISSID#*ssid=\"}
WIFISSID=${WIFISSID%\"*}

WIFIPASSW=${WIFIPASSW#*#psk=\"}
WIFIPASSW=${WIFIPASSW%\"*}

WIFIAP="{\"SSID\":\"$WIFISSID\",\"passkey\":\"$WIFIPASSW\"}"

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\",\"wired\":$LANCFG,\"wifi\":$WIFICFG,\"wifiap\":$WIFIAP,\"dnsip\":\"$GDNS\",\"ntpip\":\"$GNTP\"}"
