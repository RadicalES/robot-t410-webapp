#!/bin/sh
# 
# setnwkcfg.sh
# CGI Script to setup the network interfaces.
#
# (C) 2016-2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

WIRED_IPADDR="192.168.1.20"
WIRED_NETMASK="255.255.255.0"
WIRED_GATEWAY="192.168.1.1"
WIRED_DHCP="NOTSET"
WIRED_METRIC="10"
WIRED_IFDEV=eth0

WIFI_ENABLE="FALSE"
WIFI_IPADDR="192.168.100.20"
WIFI_NETMASK="255.255.255.0"
WIFI_GATEWAY="192.168.100.1"
WIFI_DHCP="NOTSET"
WIFI_METRIC="20"
WIFI_IFDEV=wlan0
WIFI_SSID=""
WIFI_KEY=""

NTP_IPADDR=""
DNS_IPADDR=""

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

        if [ $1 == "wired_ipaddr" ]; then
            WIRED_IPADDR=$2
        elif [ $1 == "wired_gateway" ]; then
            WIRED_GATEWAY=$2
        elif [ $1 == "wired_netmask" ]; then
            WIRED_NETMASK=$2
        elif [ $1 == "wired_dhcp" ]; then
            WIRED_DHCP=$2
        elif [ $1 == "wired_metric" ]; then
            WIRED_METRIC=$2
        elif [ $1 == "wifi_enable" ]; then
            WIFI_ENABLE=$2
        elif [ $1 == "wifi_ipaddr" ]; then
            WIFI_IPADDR=$2
        elif [ $1 == "wifi_gateway" ]; then
            WIFI_GATEWAY=$2
        elif [ $1 == "wifi_netmask" ]; then
            WIFI_NETMASK=$2
        elif [ $1 == "wifi_dhcp" ]; then
            WIFI_DHCP=$2
        elif [ $1 == "wifi_metric" ]; then
            WIFI_METRIC=$2
        elif [ $1 == "wifi_ssid" ]; then
            WIFI_SSID=$2
        elif [ $1 == "wifi_passkey" ]; then
            WIFI_KEY=$2    
        elif [ $1 == "ntp_ipaddr" ]; then
            NTP_IPADDR=$2
        elif [ $1 == "dns_ipaddr" ]; then
            DNS_IPADDR=$2

    #    else
    #	echo -en "Unknown tag=$1 value=$2\n" >> interfaces.txt
        fi
    done

    IFS="$OIFS"
}


configure_lan () {
    LOOP_IFCFG="# /etc/network/interfaces -- configuration file for ifup(8), ifdown(8)\n\n# The loopback interface\nauto lo\niface lo inet loopback\n"
    WIRED_IFCFG="# Wired interface\nauto eth0"

    echo -e $LOOP_IFCFG > /etc/network/interfaces

    if [ $WIRED_DHCP == "TRUE" ]; then
        WIRED_IFCFG="$WIRED_IFCFG\niface eth0 inet dhcp\n"
    else 
        WIRED_IFCFG="$WIRED_IFCFG\niface eth0 inet static\n\taddress $WIRED_IPADDR\n\tnetmask $WIRED_NETMASK\n\tgateway $WIRED_GATEWAY\n\tmetric $WIRED_METRIC\n"
    fi

    echo -e $WIRED_IFCFG >> /etc/network/interfaces
}

configure_wifi () {
    WIFI_IFCFG="# WIFI interface\nauto wlan0"
    WIFI_IFCFG_POST="\twpa-driver  wext\n\twpa-conf  /etc/wpa_supplicant.conf"

    if [ $WIFI_DHCP == "TRUE" ]; then
        WIFI_IFCFG="$WIFI_IFCFG\niface wlan0 inet dhcp\n"
    else 
        WIFI_IFCFG="$WIFI_IFCFG\niface wlan0 inet static\n\taddress $WIFI_IPADDR\n\tnetmask $WIFI_NETMASK\n\tgateway $WIFI_GATEWAY\n\tmetric $WIFI_METRIC\n"
    fi

    WIFI_IFCFG="$WIFI_IFCFG$WIFI_IFCFG_POST\n"
    echo -e $WIFI_IFCFG >> /etc/network/interfaces

    if [ "$WIFI_SSID" != "" ]; then
        echo -e "ctrl_interface=/run/wpa_supplicant" > /etc/wpa_supplicant.conf
        echo -e "ctrl_interface_group=0" >> /etc/wpa_supplicant.conf
        echo -e "update_config=1" >> /etc/wpa_supplicant.conf
        wpa_passphrase $WIFI_SSID $WIFI_KEY >> /etc/wpa_supplicant.conf
        # switch AP mode
    fi

}

echo -e "Content-Type: application/json\r\n\r\n"

if [ "$REQUEST_METHOD" = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
        read -n $CONTENT_LENGTH POST_DATA <&0
        parse_params $POST_DATA

        if [ $WIRED_DHCP != "NOTSET" ]; then
            configure_lan
        fi

        if [ $WIFI_DHCP != "NOTSET" ] && [ $WIFI_ENABLE != "FALSE" ]; then
            configure_wifi
        fi

        echo -e "# FILE AUTOMATICALLY GENERATED BY ROBOT-T410\n" >> /etc/network/interfaces

        if [ "$DNS_IPADDR" != "" ]; then
            echo -e $DNS_IPADDR > /etc/network/resolve.static.conf
        fi
        echo -e "{\"status\":\"OK\"}"
    else 
        echo -e "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo -e "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi

