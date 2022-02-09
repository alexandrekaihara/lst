#!/bin/bash

# Start services
service apache2 start
service ssh start
service cron start

# Keep alive
tail -f /dev/null