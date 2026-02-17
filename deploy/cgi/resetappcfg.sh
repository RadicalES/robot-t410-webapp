#!/bin/sh
#
# resetappcfg.sh
# CGI Script to reset application configuration to defaults
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

echo "Access-Control-Allow-Origin: *"
echo "Content-Type: application/json"
echo ""

CFGFILE=/etc/formfactor/app.conf

cat > "$CFGFILE" <<'EOF'
# Robot-T430 Application Settings
# (C) 2017-2026, Radical Electronic Systems

SERVER_CONFIG_URL=http://www.radicalsystems.co.za
API_PROTOCOL=ROBOT-API
APP_ENGINE=TERMINAL
SCALE_TYPE=RICHTER
TAG_NAME=T430
START_APP=DESKTOP
EOF

if [ $? -eq 0 ]; then
    echo '{"status":"OK","message":"Application settings reset to defaults"}'
else
    echo '{"status":"ERROR","message":"Failed to reset application settings"}'
fi
