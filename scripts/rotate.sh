#!/bin/bash
# Keeps only the newest N log files in a folder
# usage: rotate.sh LOGDIR [KEEP]   (KEEP defaults to 3)
DIR=$1
KEEP=$2
if [ -z $KEEP ]; then KEEP=3; fi
cd $DIR
COUNT=`ls *.log | wc -l`
if [ $COUNT -gt $KEEP ]; then
  ls -t *.log | tail -n +$(($KEEP+1)) | xargs rm
fi
echo "kept `ls *.log | wc -l` logs"
