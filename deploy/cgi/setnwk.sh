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

# Default to eth0
if [ -z "$IFACE" ]; then
    IFACE="eth0"
fi

# The interface has to be one this terminal actually has. Everything below
# reaches NetworkManager with it, and this arrives from a web request.
case "$IFACE" in
    *[!a-zA-Z0-9]*) IFACE="" ;;
esac
if [ -z "$IFACE" ] || [ ! -e "/sys/class/net/${IFACE}" ]; then
    echo '{"status":"ERROR","message":"Unknown interface"}'
    exit 0
fi

# Find the NetworkManager connection to modify.
#
# Matching on the DEVICE column alone only finds connections that are up, so
# saving with the cable unplugged answered "No connection found for eth0" —
# which is exactly when someone is likely to be setting a static address so the
# terminal comes up correctly on the next plug-in. Fall back to the profile's
# own interface-name binding, and then to type, because Debian's stock "Wired
# connection 1" is bound to no interface at all.
CON_NAME=$(timeout 5 nmcli -t -g NAME,DEVICE con show 2>/dev/null \
           | grep ":${IFACE}$" | head -1 | cut -d':' -f1)

if [ -z "$CON_NAME" ]; then
    timeout 5 nmcli -t -g NAME con show 2>/dev/null > /tmp/setnwk.cons.$$
    while IFS= read -r C; do
        BOUND=$(timeout 5 nmcli -g connection.interface-name con show "$C" 2>/dev/null)
        if [ "$BOUND" = "$IFACE" ]; then
            CON_NAME="$C"
            break
        fi
    done < /tmp/setnwk.cons.$$
    rm -f /tmp/setnwk.cons.$$
fi

if [ -z "$CON_NAME" ]; then
    if [ -d "/sys/class/net/${IFACE}/wireless" ] || [ -d "/sys/class/net/${IFACE}/phy80211" ]; then
        WANT_TYPE=802-11-wireless
    else
        WANT_TYPE=802-3-ethernet
    fi
    CON_NAME=$(timeout 5 nmcli -t -f NAME,TYPE con show 2>/dev/null \
               | awk -F: -v t="$WANT_TYPE" '$2==t {print $1; exit}')
fi

if [ -z "$CON_NAME" ]; then
    echo "{\"status\":\"ERROR\",\"message\":\"No connection profile found for $IFACE\"}"
    exit 0
fi

CUR_METHOD=$(timeout 5 nmcli -g ipv4.method con show "$CON_NAME" 2>/dev/null)

if [ "$DHCP" = "auto" ]; then
    # Already on DHCP: nothing to write, and no reason to bounce the link.
    # Saving this page also saves the scanner settings, and an operator
    # changing a port number should not lose the network while it reconnects.
    if [ "$CUR_METHOD" = "auto" ]; then
        echo '{"status":"OK","message":"No network changes"}'
        exit 0
    fi
    OUT=$(sudo nmcli con mod "$CON_NAME" ipv4.method auto ipv4.addresses "" ipv4.gateway "" ipv4.dns "" 2>&1)
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

    # Same idea: if the profile already says exactly this, leave it alone
    # rather than reconnecting the interface for no change.
    CUR_ADDR=$(timeout 5 nmcli -g ipv4.addresses con show "$CON_NAME" 2>/dev/null | head -1)
    CUR_GW=$(timeout 5 nmcli -g ipv4.gateway con show "$CON_NAME" 2>/dev/null)
    CUR_DNS=$(timeout 5 nmcli -g ipv4.dns con show "$CON_NAME" 2>/dev/null | tr ',' ' ' | awk '{print $1}')
    if [ "$CUR_METHOD" = "manual" ] && \
       [ "$CUR_ADDR" = "${IPADDR}/${PREFIX}" ] && \
       [ "$CUR_GW" = "$GATEWAY" ] && \
       [ "$CUR_DNS" = "${DNS:-$GATEWAY}" ]; then
        echo '{"status":"OK","message":"No network changes"}'
        exit 0
    fi

    OUT=$(sudo nmcli con mod "$CON_NAME" \
        ipv4.method manual \
        ipv4.addresses "${IPADDR}/${PREFIX}" \
        ipv4.gateway "$GATEWAY" \
        ipv4.dns "${DNS:-$GATEWAY}" 2>&1)
    RESULT=$?
fi

if [ $RESULT -ne 0 ]; then
    # What nmcli said, rather than a flat "failed" the operator cannot act on.
    MSG=$(echo "$OUT" | tr -d '"' | tr '\n' ' ')
    echo "{\"status\":\"ERROR\",\"message\":\"Failed to update network configuration: ${MSG}\"}"
    exit 0
fi

# Apply changes
OUT=$(sudo nmcli con up "$CON_NAME" 2>&1)
RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo '{"status":"OK","message":"Network configuration updated"}'
else
    echo '{"status":"OK","message":"Configuration saved, will apply on next restart"}'
fi
