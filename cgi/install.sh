#!/bin/sh

REMOTE=$1

echo Installing ROBOT T420 CGI Scripts...

# scp -r *.sh root@$REMOTE:/var/www/hiawatha/cgi/.
scp getnwk.sh root@$REMOTE:/var/www/hiawatha/cgi/.

#scp -r *.awk root@$REMOTE:/var/www/hiawatha/cgi/.

echo Installation complete
