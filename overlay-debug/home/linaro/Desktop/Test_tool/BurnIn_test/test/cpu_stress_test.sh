#!/bin/bash

ddr_size=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
if [ $ddr_size -gt 2097152 ]; then
    ddr_size=128
else
    ddr_size=64
fi

stressapptest -s $1 --pause_delay 600 --pause_duration 1 -W --stop_on_errors  -M $ddr_size&

exit 0
