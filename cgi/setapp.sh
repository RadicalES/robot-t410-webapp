#!/bin/sh
#
# setapp.sh
# CGI script to save all application related parameters
#
# (C) 2017-2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

APP_DESC="
# Robot-T410 Application Settings\n# (C) 2017-2020, Radical Electronic Systems
# http://www.radicalsystems.co.za info@radicalsystems.co.za

"

# Default Web Browser Settings
WB_LOAD_URL="http://127.0.0.1"
WB_LAYOUT="portrait"

SERWS_SVR_ENABLED=TRUE
SERWS_SVR_SPORT=ttyS2
SERWS_SVR_WPORT=8000
SERWS_SVR_FOREIGN=FALSE
SERWS_SVR_BAUD=115200

TELEM_ENABLED=FALSE
TELEM_PUBTOPIC="robot-t410/events"
TELEM_PORT=1883
TELEM_BROKER="192.168.100.1"

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

      if [ $1 == "appurl" ]; then
        WB_LOAD_URL=$2;

      elif [ $1 == "layout" ]; then
        WB_LAYOUT=$2;

      elif [ $1 == "telen" ]; then
        TELEM_ENABLED=$2

      elif [ $1 == "telbroker" ]; then
        TELEM_BROKER=$2

      elif [ $1 == "telport" ]; then
        TELEM_PORT=$2

      elif [ $1 == "telpubtopic" ]; then
        TELEM_PUBTOPIC=$2

      elif [ $1 == "srlwsen" ]; then
        SERWS_SVR_ENABLED=$2;

      elif [ $1 == "srlwsports" ]; then
        SERWS_SVR_SPORT=$2;

      elif [ $1 == "srlwsbaud" ]; then
        SERWS_SVR_BAUD=$2;

      elif [ $1 == "srlwsportn" ]; then
        SERWS_SVR_WPORT=$2;

      elif [ $1 == "srlwsforeign" ]; then
        SERWS_SVR_FOREIGN=$2;

  #    else
  #	echo -en "Unknown tag=$1 value=$2\n" >> interfaces.txt
      fi
  done

  IFS="$OIFS"
}

configure_app () {

  APP_CFG="# Window Manager Settings\nWB_LOAD_URL=$WB_LOAD_URL\nWB_LAYOUT=$WB_LAYOUT\n\n"
  TELM_CFG="# Telemetry Settings\nTELEM_ENABLED=$TELEM_ENABLED\nTELEM_BROKER=$TELEM_BROKER\nTELEM_PORT=$TELEM_PORT\nTELEM_PUBTOPIC=$TELEM_PUBTOPIC\n\n"
  SWS_CFG="# Serial Websocket Server Settings\nSERWS_SVR_ENABLED=$SERWS_SVR_ENABLED\nSERWS_SVR_SPORT=$SERWS_SVR_SPORT\nSERWS_SVR_WPORT=$SERWS_SVR_WPORT\nSERWS_SVR_FOREIGN=$SERWS_SVR_FOREIGN\nSERWS_SVR_BAUD=$SERWS_SVR_BAUD\n"

  echo -e $APP_DESC > /etc/formfactor/appconfig
  echo -e $APP_CFG >> /etc/formfactor/appconfig
  echo -e $TELM_CFG >> /etc/formfactor/appconfig
  echo -e $SWS_CFG >> /etc/formfactor/appconfig

}

restart_serial_ws_server () {
  /etc/init.d/robotws stop > /dev/null
  /etc/init.d/robotws start > /dev/null
}

echo -e "Content-Type: application/json\r\n\r\n"

if [ "$REQUEST_METHOD" = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
      read -n $CONTENT_LENGTH POST_DATA <&0
      parse_params $POST_DATA
      configure_app
      echo -e "{\"status\":\"OK\"}"
      restart_serial_ws_server
    else 
        echo -e "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo -e "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi




