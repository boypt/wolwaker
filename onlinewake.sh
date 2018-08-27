#!/usr/bin/env sh
set -o nounset

readonly SERVER_URL=http://127.0.0.1:3000/regpull
readonly WGET=/usr/bin/wget
readonly WOL=/usr/sbin/ether-wake
readonly WOL_IF=br0

CLIENTS="192.168.100.127,EC:89:14:FF:FF:FF,HUAWEI
192.168.100.129,FC:AA:14:AF:FF:FF,DESKTOP-TEST
192.168.100.194,3C:2E:F9:16:FF:FF,iPhone-2"

join_array()
{
  local STRING=""
  local DELM=$2
  for LINE in $1; do
    STRING="${STRING}${LINE}${DELM}"
  done
  echo ${STRING%${DELM}}
}

wake_by_index()
{
  local IDX=$2
  local CNT=0
  for ITM in $1; do
    if [ $IDX -eq $CNT ]; then
      local MAC=$(echo $ITM | cut -f 2 -d ',')
      eval "$WOL -i $WOL_IF $MAC" || true
      break
    fi
    CNT=$(($CNT+1))
  done
}

while true; do 
    STAS=$(join_array "$CLIENTS" '|')
    RET=$($WGET -q -T 300 -O - "${SERVER_URL}?r=${STAS}")
    if [ $? -eq 0 ] && echo $RET | grep -q '[0-9]\+'; then
      wake_by_index "$CLIENTS" $RET
    fi
    sleep 1
done
