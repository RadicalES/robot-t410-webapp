#!/bin/sh
#
# getservices.sh
# CGI script reporting whether each websocket service is enabled and running.
#
# Small and cheap on purpose: the terminal's app polls this to colour its
# reader indicators, so it does systemctl and nothing else. getcomms.sh answers
# the same question among many others, but it shells out to nmcli and reads the
# whole network configuration - fine for a settings page opened by hand, far
# too heavy for a page that asks every twenty seconds.
#
# "Enabled" and "running" are different questions and both are reported. A
# service that is not enabled is one this terminal does not have, and its
# indicator should say so quietly rather than raise an alarm; one that is
# enabled but not running is a fault.
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za

svc () {
  s_enabled=false
  case "$(systemctl is-enabled "$2" 2>/dev/null)" in
      enabled|enabled-runtime) s_enabled=true ;;
  esac
  s_running=false
  systemctl is-active --quiet "$2" 2>/dev/null && s_running=true
  printf '"%s":{"enabled":%s,"running":%s}' "$1" "$s_enabled" "$s_running"
}

printf 'Access-Control-Allow-Origin: *\r\nCache-Control: no-store\r\nContent-Type: application/json\r\n\r\n'
printf '{"status":"OK",%s,%s,%s}\n' \
    "$(svc cardreader wsrobot@cardreader)" \
    "$(svc scanner    wsrobot@scanner)" \
    "$(svc scale      wsscale)"
