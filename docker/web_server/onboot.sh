#!/bin/bash

# Start services
service apache2 start
service ssh start

# Keep alive
tail -f /dev/null
#/bin/bash