#!/bin/sh
# 
# getnwkcfg.sh
# CGI Script to retrieve the current network setup and return as JSON result
#
# (C) 2016 - 2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

IFACECFGFILE=/etc/network/interfaces
DNSCFGFILE=/etc/resolve.conf

GDNS=$(cat /etc/network/resolv.static.conf |grep -i '^nameserver'|head -n1|cut -d ' ' -f2)
GNTP=$(cat /etc/ntp.conf |grep -i '^server'|head -n1|cut -d ' ' -f2)

LANIFDEV=eth0
# source LAN settings
LANCFGFILE=/etc/systemd/network/eth0.network
LANMAC=$(cat /sys/class/net/eth0/address)
# LANIFCFG=$(awk -f readInterfaces.awk $IFACECFGFILE device=$LANIFDEV)
# RES=$?
if [ ! -f $LANCFGFILE ]; then
	# network interface not available
	LANIFCFG="{\"name\":\"$LANIFCFG\",\"status\":\"NOTAVAIL\",\"macAddress\":\"Not installed\"}"
else
	. $LANCFGFILE
	if [ -n "$Name"  ]; then

		if [ -n "$DHCP" ] && [ $DHCP == "ipv4" ]; then

			# DHCP address
			IFDATA=$(ifconfig $LANIFDEV | grep 'inet addr')
			if [ -z "$IFDATA" ]; then
				LANCFG="{\"name\":\"$LANIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$LANMAC\",\"ipAddress\":\"0.0.0.0\",\"netmask\":\"0.0.0.0\",\"gateway\":\"0.0.0.0\",\"dns\":\"0.0.0.0\",\"dhcp\":\"TRUE\"}"
			else
				IFIP=$(echo $IFDATA | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
				IFDNS=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }' | sed -n -e 'H;${x;s/\n/,/g;s/^,//;p;}')
				IFMASK=$(echo $IFDATA | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')
				IPGW=$(ip route | grep eth0 | awk '/default/ { print $3 }')
				LANCFG="{\"name\":\"$LANIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$LANMAC\",\"ipAddress\":\"$IFIP\",\"netmask\":\"$IFMASK\",\"gateway\":\"$IPGW\",\"dns\":\"$IFDNS\",\"dhcp\":\"TRUE\"}"
			fi
		
		else
			# Static address
			LANCFG="{\"macAddress\":\"$LANMAC\",\"status\":\"ENABLED\",\"name\":\"$Name\",\"ipAddress\":\"$Address\",\"gateway\":\"$Gateway\",\"dns\":\"$DNS\",\"dhcp\":\"FALSE\"}"
		fi
		
	else
		# not configured
		LANCFG="{\"name\":\"$LANIFCFG\",\"status\":\"DISABLED\",\"macAddress\":\"$LANMAC\"}"
	fi
fi

WIFIIFDEV=wlan0
# source WIFI settings
WIFICFGFILE=/etc/systemd/network/wlan0.network
WIFIMAC=$(cat /sys/class/net/wlan0/address)
# WIFIIFCFG=$(awk -f readInterfaces.awk $IFACECFGFILE device=$WIFIIFDEV)
# RES=$?

if [ ! -f $WIFICFGFILE ]; then
	# network interface not available
	WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"NOTAVAIL\",\"macAddress\":\"Not installed\"}"
else
	. $WIFICFGFILE
	if [ -n "$Name"  ]; then

		if [ -n "$DHCP" ] && [ $DHCP == "ipv4" ]; then

			# DHCP address
			WIFDATA=$(ifconfig $WIFIIFDEV | grep 'inet addr')
			if [ -z "$WIFDATA" ]; then
				WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$WIFIMAC\",\"ipAddress\":\"0.0.0.0\",\"netmask\":\"0.0.0.0\",\"gateway\":\"0.0.0.0\",\"dns\":\"0.0.0.0\",\"dhcp\":\"TRUE\"}"
			else
				IFIP=$(echo $WIFDATA | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
				IFDNS=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }' | sed -n -e 'H;${x;s/\n/,/g;s/^,//;p;}')
				IFMASK=$(echo $WIFDATA | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')
				IPGW=$(ip route | grep wlan0 | awk '/default/ { print $3 }' | sed -n -e 'H;${x;s/\n/,/g;s/^,//;p;}')
				WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$WIFIMAC\",\"ipAddress\":\"$IFIP\",\"netmask\":\"$IFMASK\",\"gateway\":\"$IPGW\",\"dns\":\"$IFDNS\",\"dhcp\":\"TRUE\"}"
			fi
		
		else

			# Static address
			WIFICFG="{\"macAddress\":\"$WIFIMAC\",\"status\":\"ENABLED\",\"name\":\"$Name\",\"ipAddress\":\"$Address\",\"gateway\":\"$Gateway\",\"dhcp\":\"FALSE\"}"

		fi
	else
		# not configured
		WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"DISABLED\",\"macAddress\":\"$WIFIMAC\"}"
	fi
fi

WIFISSID=$(cat /etc/wpa_supplicant/wpa_supplicant-wlan0.conf | grep ssid)
WIFIPASSW=$(cat /etc/wpa_supplicant/wpa_supplicant-wlan0.conf | grep "#psk")

WIFISSID=${WIFISSID#*ssid=\"}
WIFISSID=${WIFISSID%\"*}

WIFIAP="{\"SSID\":\"$WIFISSID\"}"

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\",\"wired\":$LANCFG,\"wifi\":$WIFICFG,\"wifiap\":$WIFIAP,\"dnsip\":\"$GDNS\",\"ntpip\":\"$GNTP\"}"
