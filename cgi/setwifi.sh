#!/bin/sh
# 
# setnwkcfg.sh
# CGI Script to setup the network interfaces.
#
# (C) 2016-2024, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

APP_DESC="
# Robot-T420 Wireless Settings\n# (C) 2017-2024, Radical Electronic Systems\n\
# http://www.radicalsystems.co.za info@radicalsystems.co.za\n\n
"

INTERFACE="wlan0"
ENABLED="TRUE"
IPADDR="192.168.0.20"
NETMASK="255.255.255.0"
GATEWAY="192.168.0.1"
DHCP="auto"
METRIC="200"
IFDEV=wlan0
DNS="192.168.0.1"
SSID="ROBOT"
PASSKEY="NONE"
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
        elif [ $1 == "ssid" ]; then
            SSID=$2
        elif [ $1 == "passkey" ]; then
            PASSKEY=$2

    #    else
    #	echo -en "Unknown tag=$1 value=$2\n" >> interfaces.txt
        fi
    done

    IFS="$OIFS"
}

stop_wifi () {
    # nmcli dev disconnect $INTERFACE
    nmcli connection down $INTERFACE
}

restart_wifi () {
    nmcli dev down $INTERFACE
    nmcli dev up $INTERFACE
}

restart_radio () {
    nmcli radio wifi off
    nmcli radio wifi on
}

configure_wifi_static () {
   nmcli connection add \
        type wifi \
        con-name $INTERFACE \
        ifname $INTERFACE \
        ipv4.method manual \
        ipv4.address $IPADDR \
        ipv4.gateway $GATEWAY \
        ipv4.dns $DNS \
        ipv4.route-metric $METRIC > /dev/null

    nmcli connection modify $INTERFACE \
        wifi-sec.key-mgmt \
        wpa-psk \
        wifi-sec.psk $PASSKEY

    nmcli connection up $INTERFACE
}

configure_wifi_dhcp () {
    nmcli connection add \
        type wifi \
        ifname $INTERFACE \
        con-name $INTERFACE \
        ipv4.method auto \
        ipv4.route-metric $METRIC \
        ssid $SSID > /dev/null

    nmcli connection modify $INTERFACE \
        wifi-sec.key-mgmt \
        wpa-psk \
        wifi-sec.psk $PASSKEY

    nmcli connection up $INTERFACE
}

modify_wifi () {
  nmcli connection modify $INTERFACE ipv4.dns $DNS
  #  nmcli connection modify $INTERFACE ipv4.address $IPADDR
}

modify_wifi_dhcp () {
    nmcli connection modify $INTERFACE ipv4.method auto
}

delete_wifis () {
    nmcli --terse con show | grep wireless | cut -d : -f 1 | \
        while read name; do nmcli connection delete "$name" > /dev/null; done
    # nmcli connection delete $INTERFACE
}

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"

if [ "$REQUEST_METHOD" = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
        read -n $CONTENT_LENGTH POST_DATA <&0
        parse_params $POST_DATA

        CONFIG="# Wifi Settings\nENABLED=$ENABLED\nINTERFACE=$INTERFACE\nDHCP=$DHCP\nIPADDR=$IPADDR\nNETMASK=$NETMASK\nGATEWAY=$GATEWAY\nDNS=$DNS\nMETRIC=$METRIC\nSSID=$SSID\nPASSKEY=$PASSKEY\n\n"
        echo -e $APP_DESC > /etc/formfactor/wificonfig
        echo -e $CONFIG >> /etc/formfactor/wificonfig

        # stop_wifi
        # delete_wifis

        # if [ $ENABLED = "true" ]; then
        #     if [ $DHCP = "auto" ]; then
        #         configure_wifi_dhcp
        #         RESPONSE=("$RESPONSE\"DHCP\":\"OK\"")
        #     else
        #         configure_wifi_static
        #         RESPONSE=("$RESPONSE\"DHCP\":\"DISABLED\"")
        #     fi
        # fi

        echo -e "{\"status\":\"OK\"}"
    else 
        echo -e "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo -e "{\"status\":\"FAILED\", \"message\":\"not a post\""
fi
