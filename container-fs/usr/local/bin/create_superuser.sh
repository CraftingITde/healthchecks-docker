#!/usr/bin/with-contenv bash

cd /app/healthchecks || exit 1
python3 /app/healthchecks/manage.py createsuperuser