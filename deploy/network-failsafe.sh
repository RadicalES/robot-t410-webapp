#!/bin/bash
#
# network-failsafe.sh
# Check if ENTER button (GPIO 5) is held during boot.
# If pressed, reset network to DHCP.
#
# (C) 2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za
#

GPIO_CHIP="gpiochip0"
GPIO_PIN=5
HOLD_SECONDS=3
CHECK_INTERVAL=0.5

logger -t network-failsafe "Checking GPIO $GPIO_PIN for failsafe reset..."

# Check if button is pressed (active low: 0 = pressed)
VAL=$(gpioget "$GPIO_CHIP" "$GPIO_PIN" 2>/dev/null)
if [ "$VAL" != "0" ]; then
    logger -t network-failsafe "Button not pressed, skipping."
    exit 0
fi

logger -t network-failsafe "Button pressed! Waiting ${HOLD_SECONDS}s to confirm..."

# Require button held for HOLD_SECONDS
ELAPSED=0
while [ "$(echo "$ELAPSED < $HOLD_SECONDS" | bc)" -eq 1 ]; do
    sleep "$CHECK_INTERVAL"
    ELAPSED=$(echo "$ELAPSED + $CHECK_INTERVAL" | bc)
    VAL=$(gpioget "$GPIO_CHIP" "$GPIO_PIN" 2>/dev/null)
    if [ "$VAL" != "0" ]; then
        logger -t network-failsafe "Button released early, skipping."
        exit 0
    fi
done

logger -t network-failsafe "Failsafe triggered! Resetting network to DHCP..."

# Find the wired connection name
CON_NAME=$(nmcli -t -g NAME,DEVICE con show | grep ":eth0$" | head -1 | cut -d':' -f1)
if [ -z "$CON_NAME" ]; then
    CON_NAME="Wired connection 1"
fi

nmcli con mod "$CON_NAME" ipv4.method auto ipv4.addresses "" ipv4.gateway "" ipv4.dns ""
nmcli con up "$CON_NAME"

logger -t network-failsafe "Network reset to DHCP on $CON_NAME."
