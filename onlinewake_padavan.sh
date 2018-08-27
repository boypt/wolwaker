#!/usr/bin/env sh
set -o nounset

readonly SERVER_URL=http://127.0.0.1:3100/regpull
readonly WGET=/usr/bin/wget
readonly WOL=/usr/sbin/ether-wake
readonly WOL_IF=br0
readonly STATIC_IPS=/tmp/static_ip.inf
readonly PID=/var/run/wolwaker.pid

if [ -f $PID ] && kill -0 $(cat $PID); then
  logger -s -t "WOLWaker" "WOLWaker is already running."
  exit 1
fi
echo $$ > "$PID"
trap "rm -f -- '$PID'" EXIT
# Ensure PID file is removed on program exit.

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
      logger -s -t "WOLWaker" "Wake: $ITM"
      eval "$WOL -b -i $WOL_IF $MAC" || true
      break
    fi
    CNT=$(($CNT+1))
  done
}

while true; do 
    CLIENTS=$(cat $STATIC_IPS | cut -f 1,2,3 -d ',')
    STAS=$(join_array "$CLIENTS" '|')
    RET=$($WGET -q -T 300 -O - "${SERVER_URL}?r=${STAS}")
    if echo $RET | grep -q '[0-9]\+'; then
      wake_by_index "$CLIENTS" "$RET"
    fi
    sleep 1
done
