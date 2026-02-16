#!/bin/bash
#
# index.sh
# CGI Script they will do processing by default
# Data and commands are JSON
#
# (C) 2017-2025, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

IFACE=eth0
MAC=$(cat /sys/class/net/${IFACE}/address | tr '[:lower:]' '[:upper:]')

process_restart() {
    $(sudo /sbin/reboot &)
}

process_command () {

    if [ -n "$1" ]; then

        if [ "$1" = "requestReset" ]; then

            if [ "$2" = "$MAC" ]; then
                echo "{\"status\":\"OK\"}"
                process_restart
            else 
                echo "{\"status\":\"FAILED\", \"message\":\"MAC mismatch\"}"
            fi
        else 
            echo "{\"status\":\"FAILED\", \"message\":\"command not supported\", \"command\": \"$1\"}"
        fi

        return
    fi

    echo "{\"status\":\"FAILED\", \"message\":\"no command\"}"

}

process_data () {

    OBJ=$(echo $1 | jq -cs first)
    CMD=$(echo $OBJ | jq -r 'keys[0]')
    DATA=$(echo $OBJ | jq -cs '.[0] | .[]')
    MAC_CMD=$(echo $DATA | jq -r '.MAC')
    process_command $CMD $MAC_CMD
    # echo "{\"cmd\": \"$CMD\", \"data\": \"$MAC_CMD\"}"
}

if [ $REQUEST_METHOD = "POST" ]; then
    echo -e "Access-Control-Allow-Origin: *\nContent-Type: application/json\n\n"

    if [ "$CONTENT_LENGTH" -gt 0 ]; then
      read -n $CONTENT_LENGTH POST_DATA
      process_data $POST_DATA
    else 
        echo "{\"status\":\"FAILED\", \"message\":\"no data in body\"}"
    fi

elif [ $REQUEST_METHOD = "OPTIONS" ]; then
    echo -e "Access-Control-Allow-Origin: *\nAccess-Control-Allow-Methods: GET, POST, OPTIONS\nAccess-Control-Allow-Headers: Content-Type\n\n"

else
    echo -e "Access-Control-Allow-Origin: *\nContent-Type: application/json\n\n"
    echo "{\"status\":\"FAILED\", \"message\":\"not a post\"}"

fi

