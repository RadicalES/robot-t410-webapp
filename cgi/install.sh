#!/bin/sh

REMOTE=$1

echo Installing ROBOT T420 CGI Scripts...

# scp -r *.sh root@$REMOTE:/var/www/hiawatha/cgi/.
scp get*.sh root@$REMOTE:/var/www/hiawatha/cgi/.
# scp set*.sh root@$REMOTE:/var/www/hiawatha/cgi/.
# scp reset*.sh root@$REMOTE:/var/www/hiawatha/cgi/.
# scp restart.sh root@$REMOTE:/var/www/hiawatha/cgi/.


#scp -r *.awk root@$REMOTE:/var/www/hiawatha/cgi/.

#!/bin/sh

REMOTE=$1

# rsync -av --exclude sync.sh --progress * root@$REMOTE:/var/www/hiawatha/cgi/.

echo Installation complete
