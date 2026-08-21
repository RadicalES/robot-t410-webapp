#!/bin/bash
#
# getscada.sh
# CGI Script: report the SCADA server connection + health, as maintained by the
# robot-scada-client service in /run/robot. Read-only and fast (no network), so the UI
# can poll it. JSON: {"status":"OK","scada":{state,healthy,running,serverURL,lastContact}}
#   state       ONLINE (provisioned) | UNPROVISIONED (reachable, not provisioned) | OFFLINE
#   healthy     true when ONLINE and a ping succeeded within ~3x the ping interval
#   running     is the robot-scada-client service active
#   lastContact seconds since the last successful server contact (-1 if never)
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

RUN=/run/robot
readf() { [ -r "$1" ] && cat "$1" || echo "$2"; }

STATE=$(readf "$RUN/status" OFFLINE)
SURL=$(readf "$RUN/serverURL" "")
STATION=$(readf "$RUN/station" "")
LASTOK=$(readf "$RUN/last_ok" 0)

PING_INTERVAL=30
[ -r /etc/robot/app.conf ] && . /etc/robot/app.conf
PING_INTERVAL=${PING_INTERVAL:-30}
THRESH=$((PING_INTERVAL * 3))

case "$LASTOK" in *[!0-9]*|"") LASTOK=0 ;; esac
NOW=$(date +%s)
if [ "$LASTOK" -gt 0 ]; then AGE=$((NOW - LASTOK)); else AGE=-1; fi

RUNNING=false
systemctl is-active --quiet robot-scada-client 2>/dev/null && RUNNING=true

# Whether it starts on boot is a separate question from whether it is running,
# and the difference is the one worth telling an operator about: a service that
# was switched off reads identically to one that crashed if all you report is
# "not running".
ENABLED=false
case "$(systemctl is-enabled robot-scada-client 2>/dev/null)" in
    enabled|enabled-runtime) ENABLED=true ;;
esac

HEALTHY=false
if [ "$STATE" = "ONLINE" ] && [ "$AGE" -ge 0 ] && [ "$AGE" -le "$THRESH" ]; then HEALTHY=true; fi

if [ "$REQUEST_METHOD" = "OPTIONS" ]; then
    echo -e "Access-Control-Allow-Origin: *\r\n\r\n"
else
    echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"
    echo -e "{\"status\":\"OK\",\"scada\":{\"state\":\"$STATE\",\"healthy\":$HEALTHY,\"running\":$RUNNING,\"enabled\":$ENABLED,\"station\":\"$STATION\",\"serverURL\":\"$SURL\",\"lastContact\":$AGE}}"
fi
