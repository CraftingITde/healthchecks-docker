#! /bin/sh

if [ -n "$FIFTEEN_MINUTES_WATCHDOG1" ];
then
    curl -fsS --retry 3 $FIFTEEN_MINUTES_WATCHDOG1 > /dev/null
fi

if [ -n "$FIFTEEN_MINUTES_WATCHDOG2" ];
then
    curl -fsS --retry 3 $FIFTEEN_MINUTES_WATCHDOG2 > /dev/null
fi
