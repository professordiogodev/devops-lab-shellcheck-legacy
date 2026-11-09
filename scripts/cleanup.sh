#!/bin/bash
# Empties one cache folder inside $DATA_DIR
# usage: DATA_DIR=/var/lib/clipstr cleanup.sh <subfolder>
SUBDIR=$1
echo Cleaning $DATA_DIR/$SUBDIR
rm -rf $DATA_DIR/$SUBDIR/*
echo done
