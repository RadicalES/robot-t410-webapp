#!/bin/sh
# Imitation of webdav to read and edit a file
if [ "$REMOTE_USER" != "admin" ]; then
  printf "Status: 403\r\n"
  printf "\r\n"
  printf "Only admin can change users but you are %s" "$REMOTE_USER"
  exit
fi

if [ "$REQUEST_METHOD" = "GET" ]; then
  printf "Content-Type: text/plain\r\n"
  printf "\r\n"
  cat /etc/hosts
elif [ "$REQUEST_METHOD" = "PUT" ]; then
  CONTENT=$(cat -)
  printf "%s" "$CONTENT" > /etc/hosts
  printf "Status: 204\r\n"
  printf "\r\n"
else
  printf "Status: 405\r\n"
fi