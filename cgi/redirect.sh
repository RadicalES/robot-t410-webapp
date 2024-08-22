#!/bin/sh
# Redirect from HTTP to HTTPS
printf "Status: 302 Redirect\r\n"
printf "Location: https://$SERVER_NAME:$SERVER_PORT/\r\n"
printf "\r\n"