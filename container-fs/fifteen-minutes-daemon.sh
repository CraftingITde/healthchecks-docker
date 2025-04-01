#!/bin/sh
while true; do
    echo "Running fifteen-minutes tasks..."
    if [ -n "$FIFTEEN_MINUTES_WATCHDOG1" ]; then
        curl -fsS --retry 3 $FIFTEEN_MINUTES_WATCHDOG1 > /dev/null
        echo "Pinged watchdog 1"
    fi

    if [ -n "$FIFTEEN_MINUTES_WATCHDOG2" ]; then
        curl -fsS --retry 3 $FIFTEEN_MINUTES_WATCHDOG2 > /dev/null
        echo "Pinged watchdog 2"
    fi
    
    echo "Fifteen-minutes tasks completed. Sleeping for 15 minutes..."
    sleep 900 # 15 Minuten = 900 Sekunden
done