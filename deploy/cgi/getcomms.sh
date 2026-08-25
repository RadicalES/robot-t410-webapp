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
	LANDNS=$(nmcli -g ipv4.dns con show "$LANNAME" | tr ',' ' ' | awk '{print $1}')
else
	# DHCP/auto: read the live values from the device
	LANDHCP="auto"
	LANADDR=$(nmcli -g IP4.ADDRESS dev show "$LANIF" | head -1)
	LANGW=$(nmcli -g IP4.GATEWAY dev show "$LANIF")
	LANDNS=$(nmcli -g IP4.DNS dev show "$LANIF" | tr '\n' ' ' | awk '{print $1}')
fi
LANIP="${LANADDR%%/*}"
LANPREFIX="${LANADDR##*/}"
[ "$LANPREFIX" = "$LANADDR" ] && LANPREFIX=""
LANMASK=$(prefix_to_netmask "$LANPREFIX")

# An interface with no address is not evidence of a static configuration: an
# unplugged LAN on DHCP has no lease. This used to answer that case by
# inventing 192.168.0.10 and reporting dhcp=FALSE, so the page showed DHCP
# switched off, and a save from that page would then write that invented
# address to the terminal. ipv4.method says how the interface is configured;
# the address says whether it currently has one.
[ -z "$LANIP" ] && LANIP="0.0.0.0"
[ -z "$LANGW" ] && LANGW="0.0.0.0"
[ -z "$LANDNS" ] && LANDNS="0.0.0.0"

LAN_CFG="{
    \"name\":\"$LANNAME\",
    \"type\":\"wired\",
    \"iface\":\"$LANIF\",
    \"enabled\":\"TRUE\",
    \"dhcp\":\"$LANDHCP\",
    \"macAddress\":\"$LANMAC\",
    \"ipAddress\":\"$LANIP\",
    \"netmask\":\"$LANMASK\",
    \"gateway\":\"$LANGW\",
    \"dns\":\"$LANDNS\"
  }"


# SERIAL SECTION
BAUDRATES="1200,2400,4800,9600,19200,38400,57600,115200"

# Reported from the ttysocket config the service actually reads. Enabled is not
# a key in that file — it is systemd's own answer.
#
# It used to be read from is-active, which is a different question: a service
# that is running right now but disabled comes back as enabled here and then
# does not survive a reboot, and one that is enabled but has crashed reads as
# disabled. The checkbox means "start this on boot", so is-enabled is what
# answers it, and whether it is running goes alongside rather than standing in
# for it.
CARD_ENABLED=FALSE
case "$(systemctl is-enabled wsrobot 2>/dev/null)" in
    enabled|enabled-runtime) CARD_ENABLED=TRUE ;;
esac
CARD_RUNNING=FALSE
systemctl is-active --quiet wsrobot 2>/dev/null && CARD_RUNNING=TRUE
CARD_FOREIGN=FALSE
[ "${TTYSOCKET_HOST:-foreign}" = "foreign" ] && CARD_FOREIGN=TRUE

CARDREADER_CFG="\"cardreaderConfig\":{
  \"index\":\"0\",
  \"enabled\":\"${CARD_ENABLED}\",
  \"running\":\"${CARD_RUNNING}\",
  \"foreignConnect\":\"${CARD_FOREIGN}\",
  \"serverPort\":\"${TTYSOCKET_PORT:-8100}\",
  \"outputFormat\":\"${TTYSOCKET_FORMAT:-%s}\",
  \"serialPort\":\"${TTYSOCKET_TTY##*/}\"
  }"

NET_CFG="\"networkConfig\":[$LAN_CFG]"

# systemd-timesyncd's own setting, not a per-interface one. The page used to
# show an NTP box beside the interface settings, filled from a hardcoded
# 192.168.1.1 in this script, and setnwk.sh parsed the value back and threw it
# away. Now it is read from, and written to, the place that keeps it.
NTP_SERVER=$(grep -hs '^NTP=' /etc/systemd/timesyncd.conf.d/*.conf /etc/systemd/timesyncd.conf \
             2>/dev/null | head -1 | cut -d= -f2 | awk '{print $1}')
TIME_CFG="\"timeConfig\":{\"ntp\":\"${NTP_SERVER}\"}"

COMMS_CFG="{$CARDREADER_CFG,$NET_CFG,$TIME_CFG}"
JSON="\"status\":\"OK\",\"commsConfig\":$COMMS_CFG";

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
