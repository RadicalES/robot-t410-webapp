#!/bin/sh
# 
# setnwkcfg.sh
# CGI Script to setup the network interfaces.
#
# (C) 2016-2022, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

WIRED_IPADDR="192.168.1.20"
WIRED_NETMASK="255.255.255.0"
WIRED_GATEWAY="192.168.1.1"
WIRED_DHCP="NOTSET"
WIRED_METRIC="10"
WIRED_IFDEV=eth0
WIRED_DNS="192.168.1.1"

WIFI_ENABLE="FALSE"
WIFI_IPADDR="192.168.100.20"
WIFI_NETMASK="255.255.255.0"
WIFI_GATEWAY="192.168.100.1"
WIFI_DNS="192.168.100.1"
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
        elif [ $1 == "wired_dns" ]; then
            WIRED_DNS=$2
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
    WIRED_IFCFG="[Match]\nName=eth0\n\n[Network]\nDHCP"
    WIRED_IFCFG_POST="[Resolve]"

   # echo -e $WIRED_IFCFG >> /etc/systemd/network/eth0.network

    if [ $WIRED_DHCP == "TRUE" ]; then
        WIRED_IFCFG="$WIRED_IFCFG=ipv4\n"
    else 
        WIRED_IFCFG="$WIRED_IFCFG=no\nAddress=$WIRED_IPADDR\nGateway=$WIRED_GATEWAY\n"
    fi

    WIRED_IFCFG="$WIRED_IFCFG\n$WIRED_IFCFG_POST\nDNS=$WIRED_DNS\n"
    echo -e $WIRED_IFCFG > /etc/systemd/network/eth0.network
}

configure_wifi () {
    WIFI_IFCFG="[Match]\nName=wlan0\n\n[Network]\nDHCP"
    WIFI_IFCFG_POST="[Resolve]"

    if [ $WIFI_DHCP == "TRUE" ]; then
        WIFI_IFCFG="$WIFI_IFCFG=ipv4\n"
    else 
        WIFI_IFCFG="$WIFI_IFCFG=no\nAddress=$WIFI_IPADDR\nGateway=$WIFI_GATEWAY\n"
    fi

    WIFI_IFCFG="$WIFI_IFCFG\n$WIFI_IFCFG_POST\nDNS=$WIFI_DNS\n"
    echo -e $WIFI_IFCFG > /etc/systemd/network/wlan0.network

    if [ "$WIFI_SSID" != "" ]; then
        echo -e "ctrl_interface=/run/wpa_supplicant" > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
        echo -e "ctrl_interface_group=0" >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
        echo -e "update_config=1" >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
        wpa_passphrase $WIFI_SSID $WIFI_KEY >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
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

#        if [ "$DNS_IPADDR" != "" ]; then
#            echo -e $DNS_IPADDR > /etc/network/resolve.static.conf
#        fi
        echo -e "{\"status\":\"OK\"}"
    else 
        echo -e "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo -e "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi

