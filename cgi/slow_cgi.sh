#!/bin/sh
# Slowly read and write back the request
printf "Content-Type: text/plaint\r\n"
printf "\r\n"
set | while read line; do echo $line; sleep 1; done