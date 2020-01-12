#!/bin/sh
./manage.py migrate --noinput
./manage.py compress
./manage.py collectstatic --noinput 

if [ -n "$SUPERUSER_EMAIL" ] && [ -n "$SUPERUSER_PASSWORD" ];
then
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

exec supervisord -c /etc/supervisor/supervisord.conf

