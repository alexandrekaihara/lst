#!/bin/bash

# Start services
service smbd start
service ssh start
service cron start

# Keep alive
tail -f /dev/null