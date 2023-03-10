#!/bin/bash

eth0=$(sudo ifconfig eth0 | grep "eth0")
if [ "$eth0" == "" ]
then
	echo "eth0 not exist"
	exit
fi

# Enable WOL for ethernet : g=on, d=off
/usr/sbin/ethtool -s eth0 wol g
