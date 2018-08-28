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

main()
{
    local HOSTNAME=$(hostname)
    while true; do
        local CLIENTS="$(cat $STATIC_IPS | cut -f 1,2,3 -d ',')"
        local STAS="$(echo "$CLIENTS" | tr '\n' '|')"
        local RET=$($WGET -q -T 300 -O - "${SERVER_URL}?hostname=${HOSTNAME}&r=${STAS}")
        if echo "$RET" | grep -q '^[0-9]\+$'; then
            local MAC=$(echo "$CLIENTS" | sed -n "$(($RET+1))"p | cut -f 2 -d ',')
            if [ ! -z $MAC ]; then
                logger -s -t "WOLWaker" "Wake: $MAC"
                eval "$WOL -b -i $WOL_IF $MAC &"
            fi
        fi
        sleep 1
    done
}

main
