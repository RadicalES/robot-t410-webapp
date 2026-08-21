#!/bin/sh
#
# resetcommscfg.sh
# CGI Script to reset communications configuration to defaults
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

echo "Access-Control-Allow-Origin: *"
echo "Content-Type: application/json"
echo ""

# One config for the bridge now — /etc/ttysocket/ttysocket.conf, read by the
# packaged service — so this goes through the same helper the Card Reader page
# uses, which preserves the deployment-level settings (tty, baud, mode, card
# type) and restarts the service.
if [ -x /usr/local/sbin/ttysocket-config ]; then
    /usr/bin/sudo -n /usr/local/sbin/ttysocket-config 8100 foreign '[CARD]:%s' TRUE >/dev/null 2>&1 || true
fi

echo '{"status":"OK","message":"Communications settings reset to defaults"}'
