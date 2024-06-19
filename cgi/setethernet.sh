#!/bin/sh
# 
# setnwkcfg.sh
# CGI Script to setup the network interfaces.
#
# (C) 2016-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

APP_DESC="
# Robot-T420 Application Settings\n# (C) 2017-2024, Radical Electronic Systems\n\
# http://www.radicalsystems.co.za info@radicalsystems.co.za\n\n
"

INTERFACE="eth0"
ENABLED="TRUE"
IPADDR="192.168.1.20"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.1"
DHCP="auto"
METRIC="100"
IFDEV=eth0
DNS="192.168.1.1"
NTP=""

IFACECFGFILE=/etc/network/interfaces

parse_params () {
    PARAM=$1
    OIFS="$IFS"
    IFS='&'
    set -- $PARAM
    IFS=' '
    PARAMS=$@
    IFS="$OIFS"

    for i in $PARAMS; do
        # process "$i"
        IFS='=';
        set -- $i;

        if [ $1 == "enabled" ]; then
            ENABLED=$2
        elif [ $1 == "ipaddr" ]; then
            IPADDR=$2
        elif [ $1 == "gateway" ]; then
            GATEWAY=$2
        elif [ $1 == "netmask" ]; then
            NETMASK=$2
        elif [ $1 == "dhcp" ]; then
            DHCP=$2
        elif [ $1 == "metric" ]; then
            METRIC=$2
        elif [ $1 == "dns" ]; then
            DNS=$2
        elif [ $1 == "ntp" ]; then
            NTP=$2

    #    else
    #	echo -en "Unknown tag=$1 value=$2\n" >> interfaces.txt
        fi
    done

    IFS="$OIFS"
}

stop_lan () {
    # nmcli dev disconnect $INTERFACE
    nmcli connection down $INTERFACE
}

restart_lan () {
    nmcli dev down $INTERFACE
    nmcli dev up $INTERFACE
}

configure_lan_static () {
   nmcli connection add \
        type ethernet \
        con-name $INTERFACE \
        ifname $INTERFACE \
        ipv4.method manual \
        ipv4.address $IPADDR \
        ipv4.gateway $GATEWAY \
        ipv4.dns $DNS \
        ipv4.route-metric $METRIC

    nmcli connection up $INTERFACE
}

configure_lan_dhcp () {
    nmcli connection add \
        type ethernet \
        ifname $INTERFACE \
        con-name $INTERFACE \
        ipv4.method auto \
        ipv4.route-metric $METRIC

    nmcli connection up $INTERFACE
}

modify_lan () {
    nmcli connection modify $INTERFACE ipv4.dns $DNS
  #  nmcli connection modify $INTERFACE ipv4.address $IPADDR
}

modify_lan_dhcp () {
    nmcli connection modify $INTERFACE ipv4.method auto
}

delete_lan () {
    nmcli connection delete $INTERFACE
}

echo -e "Content-Type: application/json\r\n\r\n"
RESPONSE="{"

if [ "$REQUEST_METHOD" = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
        read -n $CONTENT_LENGTH POST_DATA <&0
        parse_params $POST_DATA

        CONFIG="# Ethernet Settings\nENABLED=$ENABLED\nINTERFACE=$INTERFACE\nDHCP=$DHCP\nIPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=$GATEWAY\nDNS=$DNS\nMETRIC=$METRIC\n\n"
        echo -e $APP_DESC > /etc/formfactor/etherconfig
        echo -e $CONFIG >> /etc/formfactor/etherconfig

        stop_lan
        delete_lan

        if [ $ENABLED = "true" ]; then
            if [ $DHCP = "auto" ]; then
                configure_lan_dhcp
                RESPONSE=("$RESPONSE\"DHCP\":\"OK\"")
            else
                configure_lan_static
                RESPONSE=("$RESPONSE\"DHCP\":\"DISABLED\"")
            fi
        fi

        RESPONSE=("$RESPONSE,\"status\":\"OK\"")
    else 
        echo -e "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    RESPONSE=("$RESPONSE\"status\":\"FAILED\", \"message\":\"not a post\"")
fi

RESPONSE=("$RESPONSE}")
echo -e $RESPONSE
