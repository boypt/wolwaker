#!/usr/bin/env sh
set -o nounset

readonly SERVER_URL=http://127.0.0.1:3100/regpull
readonly WGET=/usr/bin/wget
readonly WOL=/usr/sbin/ether-wake
readonly WOL_IF=br0
readonly PID=/var/run/wolwaker.pid

if [ -f $PID ] && kill -0 $(cat $PID); then
  logger -s -t "WOLWaker" "WOLWaker is already running."
  exit 1
fi
echo $$ > "$PID"
trap "rm -f -- '$PID'" EXIT
# Ensure PID file is removed on program exit.


CLIENTS="192.168.100.127,EC:89:14:FF:FF:FF,HUAWEI
192.168.100.129,FC:AA:14:AF:FF:FF,DESKTOP-TEST
192.168.100.194,3C:2E:F9:16:FF:FF,iPhone-2"

main()
{
    local HOSTNAME=$(hostname)
    while true; do
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
