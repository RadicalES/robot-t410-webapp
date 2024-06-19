#!/bin/sh

REMOTE=$1

rsync -av --exclude sync.sh --progress * root@$REMOTE:/etc/.
