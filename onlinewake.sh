#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

arg1="${1:-}"

# allow command fail:
# fail_command || true

SERVER_URL=http://127.0.0.1:3000/regpull
WGET=/usr/bin/wget
WOL=/usr/sbin/ether-wake
WOL_IF=br0

MACS="9C:8E:99:E4:CD:8D[HTPC],9C:8E:99:E4:12:34[NAS]"
while true; do 
    ret=$($WGET -q -T 300 -O - "${SERVER_URL}?r=${MACS}")
    echo "$WOL -i $WOL_IF $ret"
    sleep 1
done
