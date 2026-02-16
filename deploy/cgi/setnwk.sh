#!/bin/sh
#
# setnwk.sh
# CGI Script to configure network interfaces via NetworkManager
#
# (C) 2016-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

echo "Access-Control-Allow-Origin: *"
echo "Content-Type: application/json"
echo ""

if [ "$REQUEST_METHOD" != "POST" ]; then
    echo '{"status":"ERROR","message":"POST required"}'
    exit 0
fi

# Read POST body
read -r BODY

# Parse URL-encoded parameters
get_param() {
    echo "$BODY" | tr '&' '\n' | grep "^${1}=" | cut -d'=' -f2- | sed 's/+/ /g;s/%2F/\//g;s/%3A/:/g;s/%20/ /g'
}

IFACE=$(get_param "iface")
DHCP=$(get_param "dhcp")
IPADDR=$(get_param "ipaddr")
NETMASK=$(get_param "netmask")
GATEWAY=$(get_param "gateway")
DNS=$(get_param "dns")
NTP=$(get_param "ntp")

# Default to eth0
if [ -z "$IFACE" ]; then
    IFACE="eth0"
fi

# Find the NetworkManager connection name for this interface
CON_NAME=$(nmcli -t -g NAME,DEVICE con show | grep ":${IFACE}$" | head -1 | cut -d':' -f1)

if [ -z "$CON_NAME" ]; then
    echo "{\"status\":\"ERROR\",\"message\":\"No connection found for $IFACE\"}"
    exit 0
fi

if [ "$DHCP" = "auto" ]; then
    # Set to DHCP
    sudo nmcli con mod "$CON_NAME" ipv4.method auto ipv4.addresses "" ipv4.gateway "" ipv4.dns "" 2>&1
    RESULT=$?
else
    # Set static IP
    if [ -z "$IPADDR" ] || [ -z "$NETMASK" ] || [ -z "$GATEWAY" ]; then
        echo '{"status":"ERROR","message":"IP address, netmask and gateway required for static config"}'
        exit 0
    fi

    # Convert netmask to CIDR prefix
    case "$NETMASK" in
        255.255.255.0)   PREFIX=24 ;;
        255.255.0.0)     PREFIX=16 ;;
        255.0.0.0)       PREFIX=8 ;;
        255.255.255.128) PREFIX=25 ;;
        255.255.255.192) PREFIX=26 ;;
        255.255.255.224) PREFIX=27 ;;
        255.255.255.240) PREFIX=28 ;;
        255.255.255.248) PREFIX=29 ;;
        255.255.255.252) PREFIX=30 ;;
        255.255.128.0)   PREFIX=17 ;;
        255.255.192.0)   PREFIX=18 ;;
        255.255.224.0)   PREFIX=19 ;;
        255.255.240.0)   PREFIX=20 ;;
        255.255.248.0)   PREFIX=21 ;;
        255.255.252.0)   PREFIX=22 ;;
        255.255.254.0)   PREFIX=23 ;;
        *) PREFIX=24 ;;
    esac

    sudo nmcli con mod "$CON_NAME" \
        ipv4.method manual \
        ipv4.addresses "${IPADDR}/${PREFIX}" \
        ipv4.gateway "$GATEWAY" \
        ipv4.dns "${DNS:-$GATEWAY}" 2>&1
    RESULT=$?
fi

if [ $RESULT -ne 0 ]; then
    echo '{"status":"ERROR","message":"Failed to update network configuration"}'
    exit 0
fi

# Apply changes
sudo nmcli con up "$CON_NAME" 2>&1
RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo '{"status":"OK","message":"Network configuration updated"}'
else
    echo '{"status":"OK","message":"Configuration saved, will apply on next restart"}'
fi
