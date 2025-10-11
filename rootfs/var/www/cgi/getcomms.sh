#!/bin/bash
#
# getcomms.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CARDCFGFILE=/etc/formfactor/cardreader.conf
PALPICFGFILE=/etc/formfactor/palpi.conf
PALPISETUPFILE=/etc/formfactor/palpi_settings.py

SERVER_CONFIG_URL="http://www.radicalsystems.co.za"
TAG_NAME="NOT SET"

if [ -e $CARDCFGFILE ]; then
  . $CARDCFGFILE
fi

if [ -e $PALPICFGFILE ]; then
  . $PALPICFGFILE
fi

if [ -e $PALPISETUPFILE ]; then
  . $PALPISETUPFILE
fi


CONNECTIONS=$(nmcli -g NAME,TYPE,ACTIVE,STATE,UUID,DEVICE con show)

# ETHERNET SECTION
LANINFO=$(echo $CONNECTIONS | grep '802-3-ethernet')
LANNAME=$(echo $LANINFO | awk -F ':' '{print $1}')
LANUUID=$(echo $LANINFO | awk -F ':' '{print $5}')
LANIF="eth0"
# LANIF=$(echo $LANINFO | awk -F ':' '{print $6}')
LANMAC=$(cat /sys/class/net/$LANIF/address)
LANDHCP=$(nmcli -g IPV4.METHOD con show "$LANNAME")

if [ -n "$LANDHCP" ] && [ $LANDHCP == "auto" ]; then
	LANCFG=$(ifconfig $LANIF | grep 'inet')
	LANIP=$(echo $LANCFG | awk '/inet / {print $2}')
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


# SERIAL SECTION
BAUDRATES="1200,2400,4800,9600,19200,38400,57600,115200"

CARDREADER_CFG="\"cardreaderConfig\":{
  \"index\":\"0\",
  \"enabled\":\"$CARDWS_SVR_ENABLED\",
  \"foreignConnect\":\"$CARDWS_SVR_FOREIGN\",
  \"serverPort\":\"$CARDWS_SVR_WPORT\",
  \"outputFormat\":\"$CARDWS_OUTPUT_FORMAT\"
  }"

NET_CFG="\"networkConfig\":[$LAN_CFG]"

PALPI_CFG="\"palpiConfig\":{
 \"index\":\"0\",
  \"enabled\":\"$PALPI_SERVICE_ENABLED\",
  \"localPort\":\"$PALPI_SERVICE_PORT\",
  \"remoteURL\":\"$PALPI_API_URL\",
  \"printMode\":\"$PALPI_PRINT_MODE\"
}"

COMMS_CFG="{$CARDREADER_CFG,$NET_CFG,$PALPI_CFG}"
JSON="\"status\":\"OK\",\"commsConfig\":$COMMS_CFG";

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
