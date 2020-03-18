#!/bin/bash

set -e

if [ "$WG_GUI" = true ] ; then
    echo 'Starting GUI'
    /usr/bin/node /opt/wg-dashboard/src/server.js &

fi


# Install Wireguard. This has to be done dynamically since the kernel
# module depends on the host kernel version.
apt update
apt install -y linux-headers-$(uname -r) wireguard

interface=/etc/wireguard/${WG_INTERFACE}.conf
if [ ! -f "$interface" ]; then
    echo "$FILE does not exist"
    exit 1
fi

echo "$(date): Starting Wireguard"
wg-quick up $interface

# Handle shutdown behavior
finish () {
    echo "$(date): Shutting down Wireguard"
    wg-quick down $interface
    exit 0
}

trap finish SIGTERM SIGINT SIGQUIT

sleep infinity &
wait $!
