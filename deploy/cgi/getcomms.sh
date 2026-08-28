#!/bin/bash
#
# getcomms.sh
# CGI Script to retrieve the device environment data
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za


# One config per service, named after what is attached to it. Sourced in
# subshells below rather than here: all three use the same TTYSOCKET_* names,
# so sourcing them into one shell would leave the last one read standing for
# all of them.
CARDCFGFILE=/etc/ttysocket/cardreader.conf
SCANCFGFILE=/etc/ttysocket/scanner.conf
SCALECFGFILE=/etc/ttysocket/scale.conf
SERVER_CONFIG_URL="http://www.radicalsystems.co.za"
TAG_NAME="NOT SET"


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
# Each bridge is one unit and one config. Enabled is not a key in the file —
# it is systemd's own answer, and for an instance the unit is named after the
# service: wsrobot@cardreader, wsrobot@scanner. The scale is wsscale.
#
# It used to be read from is-active, which is a different question: a service
# that is running right now but disabled comes back as enabled here and then
# does not survive a reboot, and one that is enabled but has crashed reads as
# disabled. The checkbox means "start this on boot", so is-enabled is what
# answers it, and whether it is running goes alongside rather than standing in
# for it.
svc_enabled() {
    case "$(systemctl is-enabled "$1" 2>/dev/null)" in
        enabled|enabled-runtime) echo TRUE ;;
        *) echo FALSE ;;
    esac
}

svc_running() {
    if systemctl is-active --quiet "$1" 2>/dev/null; then echo TRUE; else echo FALSE; fi
}

# The node the config points at. A config may name a port through its
# /dev/serial/by-id link - which is what survives a replug, and what the helper
# writes - so it is resolved here: the page matches this against a list of node
# names, and an unresolved link matches nothing and reads as "not present".
node_of() {
    [ -n "$1" ] || return 0
    n_dev=$(readlink -f "$1" 2>/dev/null)
    [ -n "$n_dev" ] || n_dev="$1"
    echo "${n_dev##*/}"
}

# A wsRobot bridge — the card reader or the scanner. Read in a subshell so one
# service's TTYSOCKET_* values cannot leak into the next.
wsrobot_json() {
    r_key="$1" r_unit="$2" r_conf="$3" r_port="$4" r_format="$5"
    (
        TTYSOCKET_PORT="$r_port"
        TTYSOCKET_FORMAT="$r_format"
        TTYSOCKET_TTY=""
        TTYSOCKET_HOST=foreign
        [ -e "$r_conf" ] && . "$r_conf"
        r_foreign=FALSE
        [ "${TTYSOCKET_HOST:-foreign}" = "foreign" ] && r_foreign=TRUE
        echo "\"${r_key}\":{
  \"index\":\"0\",
  \"configured\":\"$([ -e "$r_conf" ] && echo TRUE || echo FALSE)\",
  \"enabled\":\"$(svc_enabled "$r_unit")\",
  \"running\":\"$(svc_running "$r_unit")\",
  \"foreignConnect\":\"${r_foreign}\",
  \"serverPort\":\"${TTYSOCKET_PORT}\",
  \"outputFormat\":\"${TTYSOCKET_FORMAT}\",
  \"serialPort\":\"$(node_of "${TTYSOCKET_TTY}")\"
  }"
    )
}

CARDREADER_CFG=$(wsrobot_json cardreaderConfig wsrobot@cardreader "$CARDCFGFILE" 8100 '[CARD]:%s')
SCANNER_CFG=$(wsrobot_json scannerConfig wsrobot@scanner "$SCANCFGFILE" 8102 '[SCAN]:%s')

# The scale keeps its own key names and has no output format: wsScale sends
# structured readings, and its model, units and limits come from the server
# rather than from this page.
SCALE_CFG=$(
    TTYSCALE_PORT=8101
    TTYSCALE_TTY=""
    TTYSCALE_HOST=foreign
    TTYSCALE_MODEL=""
    TTYSCALE_SETUP=/run/robot/setup.json
    [ -e "$SCALECFGFILE" ] && . "$SCALECFGFILE"

    s_foreign=FALSE
    [ "${TTYSCALE_HOST:-foreign}" = "foreign" ] && s_foreign=TRUE

    # Who decides which scale this is. When the server's setup names one,
    # wsScale reads it after the local file and the server wins - so the page
    # shows it and does not offer a choice that would not take effect. With no
    # server the terminal names its own, and the site's units and limits do not
    # apply because there is no site.
    s_from_server=""
    if [ -r "$TTYSCALE_SETUP" ]; then
        s_from_server=$(sed -n 's/.*"scale"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
                        "$TTYSCALE_SETUP" | head -1)
    fi
    # The effective one, and both halves separately: the page lets the local
    # protocol be set even while a server is naming one, so that a terminal can
    # be prepared for the day it runs standalone.
    s_model="${s_from_server:-$TTYSCALE_MODEL}"
    s_source=local
    [ -n "$s_from_server" ] && s_source=server

    # What this build can decode, for the page to offer.
    s_protocols=$(/usr/local/bin/wsScale -l 2>/dev/null \
                  | sed -n 's/^\([A-Z0-9-]\{3,\}\)$/"\1"/p' | paste -sd, -)

    echo "\"scaleConfig\":{
  \"index\":\"0\",
  \"configured\":\"$([ -e "$SCALECFGFILE" ] && echo TRUE || echo FALSE)\",
  \"enabled\":\"$(svc_enabled wsscale)\",
  \"running\":\"$(svc_running wsscale)\",
  \"foreignConnect\":\"${s_foreign}\",
  \"serverPort\":\"${TTYSCALE_PORT}\",
  \"serialPort\":\"$(node_of "${TTYSCALE_TTY}")\",
  \"model\":\"${s_model}\",
  \"localModel\":\"${TTYSCALE_MODEL}\",
  \"serverModel\":\"${s_from_server}\",
  \"modelSource\":\"${s_source}\",
  \"protocols\":[${s_protocols}]
  }"
)

NET_CFG="\"networkConfig\":[$LAN_CFG]"

# systemd-timesyncd's own setting, not a per-interface one. The page used to
# show an NTP box beside the interface settings, filled from a hardcoded
# 192.168.1.1 in this script, and setnwk.sh parsed the value back and threw it
# away. Now it is read from, and written to, the place that keeps it.
NTP_SERVER=$(grep -hs '^NTP=' /etc/systemd/timesyncd.conf.d/*.conf /etc/systemd/timesyncd.conf \
             2>/dev/null | head -1 | cut -d= -f2 | awk '{print $1}')
TIME_CFG="\"timeConfig\":{\"ntp\":\"${NTP_SERVER}\"}"

COMMS_CFG="{$CARDREADER_CFG,$SCANNER_CFG,$SCALE_CFG,$NET_CFG,$TIME_CFG}"
JSON="\"status\":\"OK\",\"commsConfig\":$COMMS_CFG";

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
echo -e "{$JSON}"
