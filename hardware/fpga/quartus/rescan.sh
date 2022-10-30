#!/bin/bash

dev=01:00.0


if [ -z "$dev" ]; then
    echo "Error: no device specified"
    exit 1
fi

if [ ! -e "/sys/bus/pci/devices/$dev" ]; then
    dev="0000:$dev"
fi
 
if [ ! -e "/sys/bus/pci/devices/$dev" ]; then
    echo "Error: device $dev not found! doing a pci rescan"
    exit 1
fi
 
port=$(basename $(dirname $(readlink "/sys/bus/pci/devices/$dev")))

echo "this is port $port "

if [ ! -e "/sys/bus/pci/devices/$port" ]; then
    echo "Error: device $port not found"
    exit 1
fi
 
echo 1 > "/sys/bus/pci/devices/$dev/remove"

sleep 0.5

echo "Rescanning bus..."
 
echo 1 > "/sys/bus/pci/rescan"

echo 1 > "/sys/bus/pci/devices/$port/rescan"

sleep 0.5

sudo lspci -s 01:00.0 -v
