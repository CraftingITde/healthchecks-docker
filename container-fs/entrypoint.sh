#!/bin/bash

set -e  # Beenden bei Fehlern

echo "Running migrations..."
cd /app
./manage.py migrate --noinput

echo "Collecting static files..."
./manage.py collectstatic --noinput

echo "Compressing assets..."
./manage.py compress --force

if [ -n "$SUPERUSER_EMAIL" ] && [ -n "$SUPERUSER_PASSWORD" ]; then
    echo "Creating superuser if needed..."
    cat << EOF | ./manage.py shell
from django.contrib.auth.models import User;

username = 'admin';
password = '$SUPERUSER_PASSWORD';
email = '$SUPERUSER_EMAIL';

if User.objects.filter(username=username).count()==0:
    User.objects.create_superuser(username, email, password);
    print('Superuser created.');
else:
    print('Superuser creation skipped. Already exists.');
EOF
fi

echo "Starting supervisor..."
exec supervisord -c /etc/supervisor/supervisord.conf
