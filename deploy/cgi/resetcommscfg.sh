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

# One config per service, each read by its own unit, so a reset goes through
# the same helper the Comms page uses - once per service. It preserves the
# deployment-level settings (tty, baud, mode, card type) and restarts the unit.
#
# The serial port is not reset: which socket a scanner or a scale is plugged
# into is a fact about the terminal, not a setting with a sensible default, and
# clearing it would leave a bridge pointed at nothing.
#
# Only a service the terminal actually has is touched. Resetting one that was
# never configured would create its config and start it, giving the terminal a
# scanner it does not have.
if [ -x /usr/local/sbin/ttysocket-config ]; then
    [ -e /etc/ttysocket/cardreader.conf ] && \
        /usr/bin/sudo -n /usr/local/sbin/ttysocket-config \
            cardreader 8100 foreign '[CARD]:%s' TRUE >/dev/null 2>&1 || true
    [ -e /etc/ttysocket/scanner.conf ] && \
        /usr/bin/sudo -n /usr/local/sbin/ttysocket-config \
            scanner 8102 foreign '[SCAN]:%s' TRUE >/dev/null 2>&1 || true
    [ -e /etc/ttysocket/scale.conf ] && \
        /usr/bin/sudo -n /usr/local/sbin/ttysocket-config \
            scale 8101 foreign '%s' TRUE >/dev/null 2>&1 || true
fi

echo '{"status":"OK","message":"Communications settings reset to defaults"}'
