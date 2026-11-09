#!/bin/bash
# Pings a URL and reports ok / fail (exit code 0 / 1)
# usage: health.sh URL [RETRIES]
URL=$1
RETRIES=${2:-3}
i=0
while [ $i -lt $RETRIES ]
do
  curl -s -o /dev/null -w "%{http_code}" $URL > /tmp/health.out
  code=`cat /tmp/health.out`
  if [ $code == 200 ]; then
    echo "ok: $URL"
    exit 0
  fi
  i=$((i+1))
  sleep 1
done
echo "fail: $URL"
exit 1
