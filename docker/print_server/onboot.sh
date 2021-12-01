#!/bin/bash

# Start services
service smbd start
service cups start
service ssh start

# Keep alive
tail -f /dev/null
#/bin/bash