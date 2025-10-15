#!/bin/sh
REMOTE=$1

cp index.html output/.
cp -r layers output/.
cp favicon.png output/.
cp site.css output/.
cp robot.png output/.
cp w3.css output/.
# rsync -r -u --rsync-path="sudo rsync" output/*  robot@$REMOTE:/var/www/html
rsync -r -u --rsync-path="sudo rsync" output/*  /home/janz/data/hardware/robots/robot-t430/robot-t430-rootfs/var/www/html