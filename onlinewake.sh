#!/usr/bin/env sh
set -o nounset

SERVER_URL=http://127.0.0.1:3000/regpull
WGET=/usr/bin/wget
WOL=/usr/sbin/ether-wake
WOL_IF=br0

MACS="192.168.123.145,9C:8E:99:E4:00:00,HTPC|,9C:8E:99:E4:00:01,NAS|,9C:8E:99:E4:00:02,DESKTOP"

wake_by_index()
{
  local IDX=$1
  local CNT=0
  for ITM in $MACS; do
    if [ $IDX -eq $CNT ]; then
      local MAC=${ITM:0:17}
      echo "$WOL -i $WOL_IF $MAC"
      break
    fi
    let "CNT+=1"
  done
}

while true; do 
    RET=$($WGET -q -T 300 -O - "${SERVER_URL}?r=${MACS}")
    if echo $RET | grep -q '[0-9]\+'; then
      wake_by_index $RET
    fi
    sleep 1
done
