#!/bin/bash
#
# setpalpi.sh
# CGI script to save PalPi service settings
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

PALPI_DESC="
# Robot-T430 PalPi Card Reader Settings\n# (C) 2025, Paltrack (PTY) LTD
# http://www.paltrack.co.za info@paltrack.co.za\n
"

# CardReader Websocket Server Settings
PALPI_SERVICE_ENABLED=TRUE
PALPI_SERIAL_PORT="\"ttyS0\""
PALPI_SERIAL_BAUDATE=9600
PALPI_PRINT_MODE='0'
PALPI_API_URL="http://plapi:8010"
PALPI_SERVICE_PORT=5000

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

      if [ $2 = "true" ]; then
        VAL="TRUE";
      fi

      if [ $2 = "false" ]; then
        VAL="FALSE";
      fi

      if [ $1 = "enabled" ]; then
        PALPI_SERVICE_ENABLED=$VAL;

      elif [ $1 = "localPort" ]; then
        PALPI_SERVICE_PORT=$2;

      elif [ $1 = "podServerUrl" ]; then
        PALPI_POD_SERVER_URL=$2;

      elif [ $1 = "syncServerUrl" ]; then
        PALPI_SYNC_SERVER_URL=$2;

      elif [ $1 = "printMode" ]; then
        PALPI_PRINT_MODE=$2;

      # else
  	  #   echo -en "Unknown tag=$1 value=$2\n" >> /etc/formfactor/appsetting.txt
      fi
  done

  IFS="$OIFS"
}

configure_palpi () {

PALPI_CFG="# PalPi Service Settings
PALPI_SERVICE_ENABLED=$PALPI_SERVICE_ENABLED
PALPI_SERVICE_PORT=$PALPI_SERVICE_PORT\n"

  echo -e "$PALPI_DESC" > /etc/formfactor/palpi.conf
  echo -e "$PALPI_CFG" >> /etc/formfactor/palpi.conf

PALPI_SETUP="# PalPi Python Service Settings
PALPI_SERIAL_PORT=$PALPI_SERIAL_PORT
PALPI_SERIAL_BAUDATE=$PALPI_SERIAL_BAUDATE
PALPI_POD_SERVER_URL=\"$PALPI_POD_SERVER_URL\"
PALPI_SYNC_SERVER_URL=\"$PALPI_SYNC_SERVER_URL\"
PALPI_PRINT_MODE=\"$PALPI_PRINT_MODE\"\n"

  echo -e "$PALPI_DESC" > /etc/formfactor/palpi_settings.py
  echo -e "$PALPI_SETUP" >> /etc/formfactor/palpi_settings.py
}


echo -e "Access-Control-Allow-Origin: *\nContent-Type: application/json\n\n"

if [ $REQUEST_METHOD = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
      read -n $CONTENT_LENGTH POST_DATA
      parse_params $POST_DATA
      configure_palpi
      echo "{\"status\":\"OK\", \"data\":\"$RESULT\"}"
    else 
        echo "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi




