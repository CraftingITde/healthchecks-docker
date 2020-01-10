#!/bin/sh

#python3 /healthchecks/manage.py compress
#python3 /healthchecks/manage.py collectstatic
#python3 /healthchecks/manage.py migrate --noinput

#exec supervisord -c /etc/supervisor/supervisord.conf

./manage.py migrate --noinput
./manage.py compress
./manage.py collectstatic --noinput 

uwsgi uwsgi.ini