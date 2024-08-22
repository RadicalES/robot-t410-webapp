#!/bin/sh
#
# setapp.sh
# CGI script to save all application related parameters
#
# (C) 2017-2024, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

APP_DESC="
# Robot-T420 Application Settings\n# (C) 2017-2024, Radical Electronic Systems\n
# http://www.radicalsystems.co.za info@radicalsystems.co.za\n\n
"

# Default Config Server URL
SERVER_CONFIG_URL="http://127.0.0.1"

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

      if [ $1 == "serverUrl" ]; then
        SERVER_CONFIG_URL=$2;

  #    else
  #	echo -en "Unknown tag=$1 value=$2\n" >> interfaces.txt
      fi
  done

  IFS="$OIFS"
}

configure_app () {

  APP_CFG="# Application Settings\nSERVER_CONFIG_URL=$SERVER_CONFIG_URL\n\n"

  echo -e $APP_DESC > /etc/formfactor/appconfig
  echo -e $APP_CFG > /etc/formfactor/appconfig
}

echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"

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




