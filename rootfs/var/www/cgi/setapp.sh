#!/bin/bash
#
# setapp.sh
# CGI script to save all application related parameters
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

APP_DESC="
# Robot-T430 Application Settings\n# (C) 2017-2025, Radical Electronic Systems\n
# http://www.radicalsystems.co.za info@radicalsystems.co.za\n\n
"

# Default Config Server URL
SERVER_CONFIG_URL="http://127.0.0.1"
API_PROTOCOL='ROBOT-API'
APP_ENGINE='TERMINAL'
SCALE_TYPE='RICHTER'
TAG_NAME='NOT-SET'
START_APP='DESKTOP'
RESULT='NOT SET'

generate_tagname () {
    read MAC </sys/class/net/eth0/address
    POSTFIX=$(echo $MAC | sed s/://g | awk '{print toupper(substr($0,7))}')
    TAG_NAME="T430-$POSTFIX"
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
      # process "$i"
      IFS='=';
      set -- $i;

      if [ $2 = "1" ]; then
        VAL="yes";
      else
        VAL="no";
      fi

      if [ $1 = "serverUrl" ]; then
        SERVER_CONFIG_URL=$2;

      elif [ $1 = "protocol" ]; then
        API_PROTOCOL=$2;

      elif [ $1 = "tagName" ]; then
        TAG_NAME=$2;

      elif [ $1 = "scale" ]; then
        SCALE_TYPE=$2;

      elif [ $1 = "engine" ]; then
        APP_ENGINE=$2;

      elif [ $1 = "startApp" ]; then
        START_APP=$2;

      # else
  	  #   echo -en "Unknown tag=$1 value=$2\n" >> /etc/formfactor/appsetting.txt
      fi
  done

  IFS="$OIFS"
}

configure_app () {

APP_CFG="# Application Settings\n\n
SERVER_CONFIG_URL=$SERVER_CONFIG_URL\n
API_PROTOCOL=$API_PROTOCOL\n
APP_ENGINE=$APP_ENGINE\n
SCALE_TYPE=$SCALE_TYPE\n
TAG_NAME=$TAG_NAME\n
START_APP=$START_APP\n"
  echo -e "$APP_DESC" > /etc/formfactor/app.conf
  echo -e $APP_CFG >> /etc/formfactor/app.conf
}

configure_hostname () {
  echo "$TAG_NAME" > /etc/hostname
  cp /etc/hosts.d/* /etc/.
  echo "127.0.1.1       $TAG_NAME" >> /etc/hosts
  # Fix chrome error after changing hostname
  RESULT=$(sudo unlink /home/robot/.config/chromium/SingletonLock)
}

configure_ligthdm () {

  if [ $START_APP = "DESKTOP" ]; then
    sudo ln -sf /etc/lightdm/lightdm.desktop.conf /etc/lightdm/lightdm.conf.d/lightdm.conf
  else
    sudo ln -sf /etc/lightdm/lightdm.robot.conf /etc/lightdm/lightdm.conf.d/lightdm.conf
  fi

}

echo -e "Access-Control-Allow-Origin: *\nContent-Type: application/json\n\n"

if [ $REQUEST_METHOD = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
      read -n $CONTENT_LENGTH POST_DATA
      generate_tagname
      parse_params $POST_DATA
      configure_app
      configure_hostname
      configure_ligthdm
      echo "{\"status\":\"OK\", \"data\":\"$RESULT\"}"
    else 
        echo "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi




