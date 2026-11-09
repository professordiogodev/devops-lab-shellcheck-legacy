#!/bin/bash
# Copies every file in a folder to a backup folder, adding .bak
# usage: backup.sh SRC DEST
SRC=$1
DEST=$2
mkdir -p $DEST
for f in `ls $SRC`; do
  cp $SRC/$f $DEST/$f.bak
done
echo Backed up `ls $SRC | wc -l` files to $DEST
