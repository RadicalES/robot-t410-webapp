#!/bin/sh
#
# settelemetry.sh
# CGI script to save all telemetry settings
#
# (C) 2017-2024, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

APP_DESC="
# Robot-T420 Application Settings\n# (C) 2017-2024, Radical Electronic Systems\n
# http://www.radicalsystems.co.za info@radicalsystems.co.za\n\n
"

# Default Telemetry Settings
ENABLED=FALSE
PUBTOPIC="robot-t410/events"
PORT=1883
BROKER="192.168.100.1"
USER="robot"
PASSWD="t410"

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

      if [ $1 == "enabled" ]; then
        ENABLED=$2

      elif [ $1 == "broker" ]; then
        BROKER=$2

      elif [ $1 == "port" ]; then
        PORT=$2

      elif [ $1 == "user" ]; then
        USER=$2

      elif [ $1 == "passwd" ]; then
        PASSWD=$2

      elif [ $1 == "pubtopic" ]; then
        PUBTOPIC=$2

  #    else
  #	echo -en "Unknown tag=$1 value=$2\n" >> interfaces.txt
      fi
  done

  IFS="$OIFS"
}

configure_app () {

  TELM_CFG="# Telemetry Settings\nENABLED=$ENABLED\nBROKER=$BROKER\nPORT=$PORT\nUSER=$USER\nPASSWD=$PASSWD\nPUBTOPIC=$PUBTOPIC\n\n"

  echo -e $APP_DESC > /etc/formfactor/telemconfig
  echo -e $TELM_CFG > /etc/formfactor/telemconfig
}

echo -e "Content-Type: application/json\r\n\r\n"

if [ "$REQUEST_METHOD" = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
      read -n $CONTENT_LENGTH POST_DATA <&0
      parse_params $POST_DATA
      configure_app
      echo -e "{\"status\":\"OK\"}"
    else 
        echo -e "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo -e "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi




