#!/bin/sh
# 
# setnwkcfg.sh
# CGI Script set serial port settings
#
# (C) 2016-2024, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

APP_DESC="
# Robot-T420 Serial Port Settings\n# (C) 2017-2024, Radical Electronic Systems\n\
# http://www.radicalsystems.co.za info@radicalsystems.co.za\n\n
"

SERIAL_ENABLED_0="TRUE"
SERIAL_BAUDRATE_0="9600"
SERIAL_ENABLED_1="TRUE"
SERIAL_BAUDRATE_1="9600"

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

        if [ $1 == "serial_enabled_0" ]; then
            SERIAL_ENABLED_0=$2
        elif [ $1 == "serial_enabled_1" ]; then
            SERIAL_ENABLED_1=$2
        elif [ $1 == "serial_baudrate_0" ]; then
            SERIAL_BAUDRATE_0=$2
        elif [ $1 == "serial_baudrate_1" ]; then
            SERIAL_BAUDRATE_1=$2
       
    #    else
    #	echo -en "Unknown tag=$1 value=$2\n" >> interfaces.txt
        fi
    done

    IFS="$OIFS"
}


echo -e "Access-Control-Allow-Origin: *\r\nContent-Type: application/json\r\n\r\n"

if [ "$REQUEST_METHOD" = "POST" ]; then
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
        read -n $CONTENT_LENGTH POST_DATA <&0
        parse_params $POST_DATA

        CONFIG="SERIAL_ENABLED_0=$SERIAL_ENABLED_0\nSERIAL_BAUDRATE_0=$SERIAL_BAUDRATE_0\nSERIAL_ENABLED_1=$SERIAL_ENABLED_1\nSERIAL_BAUDRATE_1=$SERIAL_BAUDRATE_1\n\n"
        echo -e $APP_DESC > /etc/formfactor/serialconfig
        echo -e $CONFIG >> /etc/formfactor/serialconfig


        echo -e "{\"status\":\"OK\"}"
    else 
        echo -e "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi
else
    echo -e "{\"status\":\"FAILED\", \"message\":\"not a post\""
fi
