#!/bin/bash
#
# setcardreader.sh
# CGI script to save all card reader related parameters
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

CARDREADER_DESC="
# Robot-T430 Card Reader Settings\n# (C) 2025, Radical Electronic Systems\n
# http://www.radicalsystems.co.za info@radsys.io\n\n
"

# CardReader Websocket Server Settings
CARDWS_SVR_ENABLED=TRUE
CARDWS_SVR_SPORT=""   # empty: keep the port the terminal already has
CARDWS_SVR_WPORT=8100
CARDWS_SVR_FOREIGN=FALSE
CARDWS_CARD_SHORT=TRUE
CARDWS_OUTPUT_FORMAT="[CARD]:%s"

parse_params () {
  PARAM=$1
  OIFS="$IFS"
  IFS='&'
  set -- $PARAM
  IFS=' '
  PARAMS=$@
  IFS="$OIFS"

  for i in $PARAMS; do
      # process "$i"
      IFS='=';
      set -- $i;

      if [ $2 = "1" ]; then
        VAL="yes";
      else
        VAL="no";
      fi

      if [ $2 = "true" ]; then
        VAL="TRUE";
      fi

      if [ $2 = "false" ]; then
        VAL="FALSE";
      fi

      if [ $1 = "enabled" ]; then
        CARDWS_SVR_ENABLED=$VAL;

      elif [ $1 = "foreignConnect" ]; then
        CARDWS_SVR_FOREIGN=$VAL;

      elif [ $1 = "serverPort" ]; then
        CARDWS_SVR_WPORT=$2;

      elif [ $1 = "outputFormat" ]; then
        CARDWS_OUTPUT_FORMAT=$2;

      # Which port the reader is on. The helper checks it against this
      # device's list before writing anything - see ttysocket-config.
      elif [ $1 = "serialPort" ]; then
        CARDWS_SVR_SPORT=$2;

      # else
  	  #   echo -en "Unknown tag=$1 value=$2\n" >> /etc/robot/appsetting.txt
      fi
  done

  IFS="$OIFS"
}

configure_cardreader () {
  # The bridge is the packaged ttysocket service, configured through
  # /etc/ttysocket/ttysocket.conf. Writing the old cardreader.conf changed
  # nothing once the T430 moved to the package — no service reads it.
  #
  # The helper applies only the four settings this page owns and restarts the
  # service; the tty, baud, read mode and card type are deployment-level and it
  # preserves them.
  HOSTMODE=local
  [ "$CARDWS_SVR_FOREIGN" = "TRUE" ] && HOSTMODE=foreign

  if RESULT=$(/usr/bin/sudo -n /usr/local/sbin/ttysocket-config \
        "$CARDWS_SVR_WPORT" "$HOSTMODE" "$CARDWS_OUTPUT_FORMAT" \
        "$CARDWS_SVR_ENABLED" "$CARDWS_SVR_SPORT" 2>&1); then
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
      configure_cardreader
      echo "{\"status\":\"OK\", \"data\":\"$RESULT\"}"
    else 
        echo "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi




