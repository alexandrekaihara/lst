#!/bin/bash

# Seafile start
## Start smbd
service nginx start
su - seafile
cd /opt/seafile-server-latest
./seafile.sh start
echo -e 'alexandreamk1@gmail.com\n123\n123\n' | ./seahub.sh start

# Keep alive
tail -f /dev/null