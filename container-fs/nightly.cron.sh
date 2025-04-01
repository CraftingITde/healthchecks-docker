#!/bin/sh
while true; do
    echo "Running nightly maintenance tasks..."
    cd /app
    ./manage.py prunepings
    ./manage.py prunenotifications
    ./manage.py pruneusers
    ./manage.py prunetokenbucket
    ./manage.py pruneflips
    ./manage.py prunepingsslow
    echo "Nightly maintenance completed. Sleeping for 24 hours..."
    sleep 86400 # 24 Stunden = 86400 Sekunden
done