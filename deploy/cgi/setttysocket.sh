#!/bin/bash
#
# setttysocket.sh
# CGI script to save the settings of one websocket service — the card reader,
# the barcode scanner or the scale.
#
# One endpoint for all three, because they are the same kind of thing: a device
# on a serial port, bridged onto a websocket. It was setcardreader.sh while the
# card reader was the only one. The service is named in the request; the helper
# knows which config file and which unit that means.
#
# (C) 2017-2026, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

# The service being configured. No default: a save that forgot to say would
# otherwise silently rewrite the card reader.
WS_SERVICE=""
WS_SVR_ENABLED=TRUE
WS_SVR_SPORT=""   # empty: keep the port the terminal already has
WS_SVR_WPORT=""
WS_SVR_FOREIGN=FALSE
WS_OUTPUT_FORMAT=""
WS_SCALE_MODEL=""

# The page form-encodes what it sends, because an output format is full of the
# characters a query string uses: "[CARD]:%s" travels as %5BCARD%5D%3A%25s.
# Without this the bridge is configured with the encoding still in it and emits
# a literal %5BCARD%5D on every card - which looks like a reader fault.
urldecode () {
  printf '%b' "$(printf '%s' "$1" | sed 's/+/ /g; s/%\(..\)/\\x\1/g')"
}

parse_params () {
  PARAM=$1
  OIFS="$IFS"
  IFS='&'
  set -- $PARAM
  IFS=' '
  PARAMS=$@
  IFS="$OIFS"

  for i in $PARAMS; do
      IFS='=';
      set -- $i;

      if [ "$2" = "1" ]; then
        VAL="yes";
      else
        VAL="no";
      fi

      if [ "$2" = "true" ]; then
        VAL="TRUE";
      fi

      if [ "$2" = "false" ]; then
        VAL="FALSE";
      fi

      if [ "$1" = "service" ]; then
        WS_SERVICE=$2;

      elif [ "$1" = "enabled" ]; then
        WS_SVR_ENABLED=$VAL;

      elif [ "$1" = "foreignConnect" ]; then
        WS_SVR_FOREIGN=$VAL;

      elif [ "$1" = "serverPort" ]; then
        WS_SVR_WPORT=$2;

      elif [ "$1" = "outputFormat" ]; then
        WS_OUTPUT_FORMAT=$(urldecode "$2");

      # Which port the device is on. The helper checks it against this
      # device's list for this service before writing anything - see
      # ttysocket-config.
      elif [ "$1" = "serialPort" ]; then
        WS_SVR_SPORT=$(urldecode "$2");

      # Which scale is attached, for a terminal with no server to ask. Ignored
      # for the other services, and by the helper when a server names one.
      elif [ "$1" = "scaleModel" ]; then
        WS_SCALE_MODEL=$(urldecode "$2");
      fi
  done

  IFS="$OIFS"
}

configure_service () {
  # The helper applies only the settings this page owns and restarts the unit;
  # the baud, read mode and card type are deployment-level and it preserves
  # them. It is also the only thing that may write under /etc — the CGI runs as
  # www-data and reaches it through a narrow sudoers rule.
  HOSTMODE=local
  [ "$WS_SVR_FOREIGN" = "TRUE" ] && HOSTMODE=foreign

  # The scale is not a formatted line - wsScale sends structured readings - so
  # it has no output format to send. Passed as %s and ignored there.
  [ -n "$WS_OUTPUT_FORMAT" ] || WS_OUTPUT_FORMAT="%s"

  if RESULT=$(/usr/bin/sudo -n /usr/local/sbin/ttysocket-config \
        "$WS_SERVICE" "$WS_SVR_WPORT" "$HOSTMODE" "$WS_OUTPUT_FORMAT" \
        "$WS_SVR_ENABLED" "$WS_SVR_SPORT" "$WS_SCALE_MODEL" 2>&1); then
    RESULT="settings applied"
  else
    RESULT="failed: $RESULT"
  fi
}

echo -e "Access-Control-Allow-Origin: *\nContent-Type: application/json\n\n"

if [ $REQUEST_METHOD = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
      read -n $CONTENT_LENGTH POST_DATA
      parse_params $POST_DATA

      case "$WS_SERVICE" in
        cardreader|scanner|scale)
          configure_service
          echo "{\"status\":\"OK\", \"data\":\"$RESULT\"}"
          ;;
        *)
          echo "{\"status\":\"FAILED\", \"message\":\"unknown service '$WS_SERVICE'\"}"
          ;;
      esac
    else
        echo "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi
