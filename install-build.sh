#!/bin/sh

REMOTE=$1

echo Installing webapp
scp -r build/* root@$1:/var/www/hiawatha/.

echo Installation complete
