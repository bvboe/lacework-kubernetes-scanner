#!/bin/sh
SCAN_CACHE_FILE=/tmp/scan-cache.txt

touch $SCAN_CACHE_FILE

COMPLETE_IMAGE=$@
echo `date` Processing image $COMPLETE_IMAGE

SHA=`docker inspect --format='{{index .Id}}' $COMPLETE_IMAGE`
IMAGE=`echo $COMPLETE_IMAGE | cut -d: -f1`
TAG=`echo $COMPLETE_IMAGE | cut -d: -f2`
echo `date` Image: $IMAGE
echo `date` Tag: $TAG
echo `date` SHA256: $SHA

echo `date` Checking scan cache
if [ `cat $SCAN_CACHE_FILE | grep "$SHA" | wc -l` -gt 0 ]
then
  echo `date` Skip scan
  exit 0
fi

echo `date` Do scan
lw-scanner evaluate $IMAGE $TAG

echo `date` Registering scan in cache
echo "$SHA" >> $SCAN_CACHE_FILE
