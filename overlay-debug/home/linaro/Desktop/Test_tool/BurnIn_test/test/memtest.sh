#!/bin/bash
a="Status: PASS";
now="$(date +'%Y%m%d_%H%M')"
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

logfile="$SCRIPTPATH/../$now"_memtest.txt

test_time=$1

ddr_size=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
if [ $ddr_size -gt 2097152 ]; then
    ddr_size=512
else
    ddr_size=256
fi

echo ddr_size=$ddr_size

if [ -z "$1" ]; then
    echo "Please input test time (second)"
    exit
fi

stressapptest -s $1 -i 4 -C 4 -W --stop_on_errors -M $ddr_size > $logfile
if [ `cat $logfile | grep -c "$a" ` -gt 0 ]
then
  echo "PASS"
else
  echo "FAIL";
fi
