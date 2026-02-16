#!/bin/bash
#
# setcardreader.sh
# CGI script to save all card reader related parameters
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

CARDREADER_DESC="
# Robot-T430 Card Reader Settings\n# (C) 2025, Radical Electronic Systems\n
# http://www.radicalsystems.co.za info@radicalsystems.co.za\n\n
"

# CardReader Websocket Server Settings
CARDWS_SVR_ENABLED=TRUE
CARDWS_SVR_SPORT=ttyS0
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

      # else
  	  #   echo -en "Unknown tag=$1 value=$2\n" >> /etc/formfactor/appsetting.txt
      fi
  done

  IFS="$OIFS"
}

configure_cardreader () {

CARDREADER_CFG="# Application Settings\n\n
CARDWS_SVR_ENABLED=$CARDWS_SVR_ENABLED\n
CARDWS_SVR_FOREIGN=$CARDWS_SVR_FOREIGN\n
CARDWS_SVR_WPORT=$CARDWS_SVR_WPORT\n
CARDWS_OUTPUT_FORMAT=$CARDWS_OUTPUT_FORMAT\n
CARDWS_SVR_SPORT=ttyS0\n
CARDWS_CARD_SHORT=TRUE\n"
  echo -e "$CARDREADER_DESC" > /etc/formfactor/cardreader.conf
  echo -e $CARDREADER_CFG >> /etc/formfactor/cardreader.conf
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




