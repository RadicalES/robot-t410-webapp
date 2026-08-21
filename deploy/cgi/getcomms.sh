#!/bin/bash
#
# getcomms.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


CARDCFGFILE=/etc/ttysocket/ttysocket.conf
SERVER_CONFIG_URL="http://www.radicalsystems.co.za"
TAG_NAME="NOT SET"

if [ -e $CARDCFGFILE ]; then
  . $CARDCFGFILE
fi


CONNECTIONS=$(nmcli -g NAME,TYPE,ACTIVE,STATE,UUID,DEVICE con show)

# ETHERNET SECTION
LANINFO=$(echo $CONNECTIONS | grep '802-3-ethernet')
LANNAME=$(echo $LANINFO | awk -F ':' '{print $1}')
LANUUID=$(echo $LANINFO | awk -F ':' '{print $5}')
LANIF="eth0"
# LANIF=$(echo $LANINFO | awk -F ':' '{print $6}')
LANMAC=$(cat /sys/class/net/$LANIF/address)
LANDHCP=$(nmcli -g ipv4.method con show "$LANNAME")

prefix_to_netmask() {
	local p="$1"
	case "$p" in ''|*[!0-9]*) echo "255.255.255.0"; return;; esac
	local m=$(( 0xffffffff ^ ((1 << (32 - p)) - 1) ))
	printf '%d.%d.%d.%d' $(( (m>>24)&255 )) $(( (m>>16)&255 )) $(( (m>>8)&255 )) $(( m&255 ))
}

if [ "$LANDHCP" = "manual" ]; then
	# Static: read the configured values from the connection profile
	LANADDR=$(nmcli -g ipv4.addresses con show "$LANNAME" | head -1 | cut -d',' -f1)
	LANGW=$(nmcli -g ipv4.gateway con show "$LANNAME")
	LANDNS=$(nmcli -g ipv4.dns con show "$LANNAME" | tr ',' ' ')
else
	# DHCP/auto: read the live values from the device
	LANDHCP="auto"
	LANADDR=$(nmcli -g IP4.ADDRESS dev show "$LANIF" | head -1)
	LANGW=$(nmcli -g IP4.GATEWAY dev show "$LANIF")
	LANDNS=$(nmcli -g IP4.DNS dev show "$LANIF" | tr '\n' ' ')
fi
LANIP="${LANADDR%%/*}"
LANPREFIX="${LANADDR##*/}"
[ "$LANPREFIX" = "$LANADDR" ] && LANPREFIX=""
LANMASK=$(prefix_to_netmask "$LANPREFIX")

if [ -n "$LANIP"  ]; then	
  LAN_CFG="{
    \"name\":\"$LANNAME\",
    \"type\":\"wired\",
    \"enabled\":\"TRUE\",
    \"dhcp\":\"$LANDHCP\",
    \"macAddress\":\"$LANMAC\",
    \"ipAddress\":\"$LANIP\",
    \"netmask\":\"$LANMASK\",
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

# Reported from the ttysocket config the service actually reads. "enabled" is
# whether the service is running, not a key in the file.
CARD_ENABLED=FALSE
systemctl is-active --quiet wsrobot 2>/dev/null && CARD_ENABLED=TRUE
CARD_FOREIGN=FALSE
[ "${TTYSOCKET_HOST:-foreign}" = "foreign" ] && CARD_FOREIGN=TRUE

CARDREADER_CFG="\"cardreaderConfig\":{
  \"index\":\"0\",
  \"enabled\":\"$CARDWS_SVR_ENABLED\",
  \"foreignConnect\":\"$CARDWS_SVR_FOREIGN\",
  \"serverPort\":\"$CARDWS_SVR_WPORT\",
  \"outputFormat\":\"$CARDWS_OUTPUT_FORMAT\"
  }"

NET_CFG="\"networkConfig\":[$LAN_CFG]"

COMMS_CFG="{$CARDREADER_CFG,$NET_CFG}"
JSON="\"status\":\"OK\",\"commsConfig\":$COMMS_CFG";

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
