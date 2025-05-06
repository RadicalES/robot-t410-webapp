#!/bin/sh
REMOTE=$1

cp index.html output/.
cp favicon.png output/.
cp site.css output/.
cp robot.png output/.
cp w3.css output/.
rsync --rsync-path="sudo rsync" output/*  robot@$REMOTE:/var/www/html