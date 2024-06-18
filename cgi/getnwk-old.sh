#!/bin/sh
# 
# getnwkcfg.sh
# CGI Script to retrieve the current network setup and return as JSON result
#
# (C) 2016 - 2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

#IFACECFGFILE=/etc/network/interfaces
#DNSCFGFILE=/etc/resolve.conf

#GDNS=$(cat /etc/network/resolv.static.conf |grep -i '^nameserver'|head -n1|cut -d ' ' -f2)
#GNTP=$(cat /etc/ntp.conf |grep -i '^server'|head -n1|cut -d ' ' -f2)

# All active connections
CONNECTIONS=$(nmcli -t -f name connection show --active)
# gives eth0, SSID of WLAN

LANIFDEV=eth0
# source LAN settings
# LANCFGFILE=/etc/systemd/network/eth0.network
LANMAC=$(cat /sys/class/net/eth0/address)
LANDHCP=$(nmcli con show eth0 | grep ipv4.method | awk '{print $2}')
LANIP=$(nmcli con show eth0 | grep ipv4.addresses | awk '{print $2}')
LANGW=$(nmcli con show eth0 | grep ipv4.gateway | awk '{print $2}')
LNDNS=$(nmcli con show eth0 | grep 'ipv4.dns:' | awk '{print $2}')

# LANIFCFG=$(awk -f readInterfaces.awk $IFACECFGFILE device=$LANIFDEV)
# RES=$?
#if [ ! -f $LANCFGFILE ]; then
	# network interface not available
#	LANIFCFG="{\"name\":\"$LANIFCFG\",\"status\":\"NOTAVAIL\",\"macAddress\":\"Not installed\"}"
#else

#	. $LANCFGFILE
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
				LANCFG="{\"name\":\"$LANIFDEV\",\"status\":\"ENABLED\",\"macAddress\":\"$LANMAC\",\"ipAddress\":\"$IFIP\",\"netmask\":\"$IFMASK\",\"gateway\":\"$IPGW\",\"dns\":\"$IFDNS\",\"dhcp\":\"TRUE\"}"
			fi
		
		else
			# Static address
			LANCFG="{\"macAddress\":\"$LANMAC\",\"status\":\"ENABLED\",\"name\":\"$Name\",\"ipAddress\":\"$Address\",\"gateway\":\"$Gateway\",\"dns\":\"$DNS\",\"dhcp\":\"FALSE\"}"
		fi
		
	else
		# not configured
		LANCFG="{\"name\":\"$LANIFDEV\",\"status\":\"DISABLED\",\"macAddress\":\"$LANMAC\"}"
	fi
#fi

WIFIIFDEV=wlan0
WIFIMAC=$(nmcli dev show wlan0 | grep GENERAL.HWADDR | awk '{print $2}')
WIFIIP=$(nmcli dev show wlan0 | grep IP4.ADDRESS | awk '{print $2}')
WIFIGW=$(nmcli dev show wlan0 | grep IP4.GATEWAY | awk '{print $2}')
WIFIDNS=$(nmcli dev show wlan0 | grep IP4.DNS | awk '{print $2}')

WIFISSID='hellow' #$(nmcli con show --active | grep wifi | awk '{print $1}')
# WIFISSID1=$(nmcli con | grep wlan0 | awk '{print $1}')
# WIFISSID2=$(iw dev wlan0 info | grep ssid | awk '{print $2}')
WIFIUUID=$(nmcli con show --active | grep wifi | awk '{print $2}')
WIFICON=$(nmcli con show --active | grep wifi | awk '{print $4}')

WIFIDHCP=$(nmcli con show $WIFISSID | grep ipv4.method | awk '{print $2}')
# WIFIACTIVE=$(nmcli con show --active | grep wlan0)
WIFICHECK=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d\' -f2)
#-> yes:RobotTest




		if [ -n "$WIFIDHCP" ] && [ $WIFIDHCP == "ipv4" ]; then

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
	#else
		# not configured
	#	WIFICFG="{\"name\":\"$WIFIIFDEV\",\"status\":\"DISABLED\",\"macAddress\":\"$WIFIMAC\"}"
	#fi
#fi

#WIFISSID=$(cat /etc/wpa_supplicant/wpa_supplicant-wlan0.conf | grep ssid)
#WIFIPASSW=$(cat /etc/wpa_supplicant/wpa_supplicant-wlan0.conf | grep "#psk")

WIFISSID=${WIFISSID#*ssid=\"}
WIFISSID=${WIFISSID%\"*}

WIFIAP="{\"SSID\":\"$WIFISSID\"}"

echo -e "Content-Type: application/json\r\n\r\n"
echo -e "{\"status\":\"OK\",\"wired\":$LANCFG,\"wifi\":$WIFICFG,\"wifiap\":$WIFIAP,\"dnsip\":\"$GDNS\",\"ntpip\":\"$GNTP\"}"
