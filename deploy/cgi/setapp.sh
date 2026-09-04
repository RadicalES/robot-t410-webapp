#!/bin/bash
#
# setapp.sh
# CGI script to save all application related parameters
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

APP_DESC="
# Robot-T430 Application Settings\n# (C) 2017-2025, Radical Electronic Systems\n
# https://www.radsys.io info@radsys.io\n\n
"

# Default Config Server URL
SERVER_CONFIG_URL="http://127.0.0.1"
TRANSACTION_URL=""
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

# The page sends every value percent-encoded, because a URL carries the
# characters that would otherwise end one field and start another: a
# transaction URL with a query string used to arrive as several settings, none
# of them right. Decoded here, once, after the split - so a value may contain
# = and & and still be one value.
urldecode () {
  local s="${1//+/ }"
  printf '%b' "${s//%/\\x}"
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
      KEY="$1"
      # An empty field is a field, not a missing one: a terminal with no
      # transaction URL sends "transactionUrl=" and means it.
      VALUE="$(urldecode "${2:-}")"

      if [ "$KEY" = "serverUrl" ]; then
        SERVER_CONFIG_URL="$VALUE";

      elif [ "$KEY" = "transactionUrl" ]; then
        TRANSACTION_URL="$VALUE";

      elif [ "$KEY" = "protocol" ]; then
        API_PROTOCOL="$VALUE";

      elif [ "$KEY" = "tagName" ]; then
        TAG_NAME="$VALUE";

      elif [ "$KEY" = "scale" ]; then
        SCALE_TYPE="$VALUE";

      elif [ "$KEY" = "engine" ]; then
        APP_ENGINE="$VALUE";

      elif [ "$KEY" = "startApp" ]; then
        START_APP="$VALUE";

      # else
  	  #   echo -en "Unknown tag=$1 value=$2\n" >> /etc/robot/appsetting.txt
      fi
  done

  IFS="$OIFS"
}

configure_app () {

APP_CFG="# Application Settings\n\n
SERVER_CONFIG_URL=$SERVER_CONFIG_URL\n
TRANSACTION_URL=$TRANSACTION_URL\n
API_PROTOCOL=$API_PROTOCOL\n
APP_ENGINE=$APP_ENGINE\n
SCALE_TYPE=$SCALE_TYPE\n
TAG_NAME=$TAG_NAME\n
START_APP=$START_APP\n"
  echo -e "$APP_DESC" > /etc/robot/app.conf
  echo -e $APP_CFG >> /etc/robot/app.conf
}

# Hand the settings to the web app this terminal serves.
#
# Written through robot-scada-client's own writer, so the config a standalone
# terminal makes is the file a provisioned one gets - same fields, same shape,
# same path. The app cannot tell which of them configured it, which is the
# point: an app written against a SCADA server runs here unchanged.
#
# A terminal with no app installed has nothing to configure, and says so
# quietly: this is the ordinary case on a terminal that runs the browser.
configure_webapp () {
  [ -x /usr/local/sbin/webapp-config ] || return 0
  sudo /usr/local/sbin/webapp-config config \
      "$TAG_NAME" "$APP_ENGINE" "$API_PROTOCOL" \
      "$SERVER_CONFIG_URL" "$TRANSACTION_URL" "$SCALE_TYPE" >/dev/null 2>&1 || true
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
      configure_webapp
      configure_hostname
      configure_ligthdm
      echo "{\"status\":\"OK\", \"data\":\"$RESULT\"}"
    else 
        echo "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo "{\"status\":\"FAILED\", \"message\":\"not a post\"}"
fi




