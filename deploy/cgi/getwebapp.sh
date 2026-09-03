#!/bin/sh
#
# getwebapp.sh
# What device web app this terminal is serving: its name, its version, every
# version still on the device, and the terminal functions it supports.
#
# The supported functions are what the Application page offers. A terminal
# running an app that only prints labels should not offer to be a scale.
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za

echo "Access-Control-Allow-Origin: *"
echo "Content-Type: application/json"
echo ""

sudo /usr/local/sbin/webapp-config list 2>/dev/null \
    || echo '{"status":"OK","apps":[]}'
