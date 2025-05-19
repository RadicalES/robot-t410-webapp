#!/bin/sh
# 
# setpasswd.sh
# CGI Script to change the user password 
#
# (C) 2016-2020, Radical Electronic Systems - www.radicalsystems.co.za
# Written by Jan Zwiegers, jan@radicalsystems.co.za

# To delete
# $>sudo passwd -d `root
# Update password
# $>chpasswd "root:passwd" ctrl-D
# $>echo "root:passwd" > chpasswd
# $>echo -e "passwd\npasswd\n" | passwd root

echo -e "Content-Type: application/json\r\nr\\n"
echo -e "{\"status\":\"ERROR\", \"message\":\"not supported\"}"




