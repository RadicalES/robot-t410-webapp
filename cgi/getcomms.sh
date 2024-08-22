#!/bin/sh
#
# getapp.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CFGFILE=/etc/formfactor/appconfig

SERVER_CONFIG_URL="http://www.radicalsystems.co.za"
TAG_NAME="NOT SET"

if [ -e $CFGFILE ]; then
  . $CFGFILE
fi

CONNECTIONS=$(nmcli -g NAME,TYPE,ACTIVE,STATE,UUID,DEVICE con show)

# ETHERNET SECTION
LANINFO=$(echo $CONNECTIONS | tr ' ' '\n' | grep '802-3-ethernet')
LANNAME=$(echo $LANINFO | awk -F ':' '{print $1}')
LANUUID=$(echo $LANINFO | awk -F ':' '{print $5}')
LANIF="eth0"
# LANIF=$(echo $LANINFO | awk -F ':' '{print $6}')
LANMAC=$(cat /sys/class/net/$LANIF/address)
LANDHCP=$(nmcli -g IPV4.METHOD con show $LANNAME)

if [ -n "$LANDHCP" ] && [ $LANDHCP == "auto" ]; then
	LANCFG=$(ifconfig $LANIF | grep 'inet addr')
	LANIP=$(echo $LANCFG | awk '/inet addr/ {gsub("addr:", "", $2); print $2}')
	LANGW=$(ip route | grep $LANIF | awk '/default/ { print $3 }')
	LANDNS=$(nmcli -g IP4.DNS dev show $LANIF)
	LANMASK=$(echo $LANCFG | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')

else 
	LANCFG=$(nmcli -g ipv4 con show $LANNAME)
	LANIP=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==2 {print $3}')
	LANGW=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==2 {print $4}')
	LANDNS=$(echo $LANCFG | sed 's/::/\n/g' | awk -F ':' 'NR==1 {print $3}')
	# LANDNS=$(nmcli -g IPV4.DNS con show $LANNAME)
	LANMASK=$(ifconfig $LANNAME | awk '/inet addr/ {gsub("Mask:", "", $4); print $4}')
fi

if [ -n "$LANIP"  ]; then	
  LAN_CFG="{
    \"name\":\"$LANNAME\",
    \"type\":\"wired\",
    \"enabled\":\"TRUE\",
    \"dhcp\":\"$LANDHCP\",
    \"macAddress\":\"$LANMAC\",
    \"ipAddress\":\"$LANIP\",
    \"netmask\":\"255.255.255.0\",
    \"gateway\":\"$LANGW\",
    \"dns\":\"$LANDNS\",
    \"ntp\":\"192.168.1.1\"
  }"
else
  LAN_CFG="{
    \"name\":\"$LANNAME\",
    \"type\":\"wired\",
    \"enabled\":\"FALSE\",
    \"dhcp\":\"FALSE\",
    \"macAddress\":\"$LANMAC\",
    \"ipAddress\":\"192.168.0.10\",
    \"netmask\":\"255.255.255.0\",
    \"gateway\":\"192.168.0.1\",
    \"dns\":\"192.168.0.1\",
    \"ntp\":\"192.168.0.1\"
  }"
fi

# WIFI SECTION
WIFIINFO=$(echo $CONNECTIONS | tr ' ' '\n' | grep '802-11-wireless')
WIFINAME=$(echo $WIFIINFO | awk -F ':' '{print $1}')
WIFIUUID=$(echo $WIFIINFO | awk -F ':' '{print $5}')
# WIFIIF=$(echo $WIFIINFO | awk -F ':' '{print $6}')
WIFIIF='wlan0'
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

if [ -n "$WIFIIP"  ]; then	
  WLAN_CFG="{
    \"name\":\"$WIFINAME\",
    \"type\":\"wireless\",
    \"dhcp\":\"$WIFIDHCP\",
    \"macAddress\":\"$WIFIMAC\",
    \"ipAddress\":\"$WIFIIP\",
    \"netmask\":\"$WIFIMASK\",
    \"gateway\":\"$WIFIGW\",
    \"dns\":\"$WIFIDNS\",
    \"ntp\":\"192.168.1.1\"
    }"
else
  WLAN_CFG="{
    \"name\":\"$WIFINAME\",
    \"type\":\"wireless\",
    \"dhcp\":\"manual\",
    \"macAddress\":\"$WIFIMAC\",
    \"ipAddress\":\"192.168.1.10\",
    \"netmask\":\"255.255.255.0\",
    \"gateway\":\"192.168.1.1\",
    \"dns\":\"192.168.1.1\",
    \"ntp\":\"192.168.1.1\"
    }"
fi


# SERIAL SECTION
BAUDRATES="1200,2400,4800,9600,19200,38400,57600,115200"

SERIAL_CFG="\"serialConfig\":[{
  \"index\":\"0\",
  \"enabled\":\"TRUE\",
  \"type\":\"RS232\",
  \"baudrate\":\"9600\",
  \"baudrateOptions\":\"$BAUDRATES\"
  },{  
  \"index\":\"1\",
  \"enabled\":\"TRUE\",
  \"type\":\"RS232\",
  \"baudrate\":\"9600\",
  \"baudrateOptions\":\"$BAUDRATES\"
  }
  ]"

NET_CFG="\"networkConfig\":[$LAN_CFG,$WLAN_CFG]"

COMMS_CFG="{$SERIAL_CFG,$NET_CFG}"
JSON="\"status\":\"OK\",\"commsConfig\":$COMMS_CFG";

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
