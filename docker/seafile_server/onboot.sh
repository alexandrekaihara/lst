#!/bin/bash

# Start programs
service ssh start
service mysql start
service nginx start

cd /opt/seafile-server-latest
./seafile.sh start
./seahub.sh start

# Keep alive
tail -f /dev/null