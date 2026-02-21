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

cat > /etc/formfactor/cardreader.conf <<'EOF'
# Robot-T430 Card Reader Settings
# (C) 2025, Radical Electronic Systems

CARDWS_SVR_ENABLED=TRUE
CARDWS_SVR_FOREIGN=TRUE
CARDWS_SVR_WPORT=8100
CARDWS_OUTPUT_FORMAT=[CARD]:%s
CARDWS_SVR_SPORT=ttyS0
CARDWS_CARD_SHORT=TRUE
EOF

cat > /etc/formfactor/serial.conf <<'EOF'
SERIAL_ENABLED_0=false
nSERIAL_BAUDRATE_0=9600
SERIAL_ENABLED_1=false
nSERIAL_BAUDRATE_1=9600
EOF

echo '{"status":"OK","message":"Communications settings reset to defaults"}'
