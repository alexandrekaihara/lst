#!/bin/bash


# Seafile start
## Start smbd
systemctl start nginx 
su - seafile
cd /opt/seafile-server-latest
./seafile.sh start
echo -e 'alexandreamk1@gmail.com\n123\n123\n' | ./seahub.sh start


# Web server start
## Start services
service apache2 start
service ssh start


# Keep alive
tail -f /dev/null