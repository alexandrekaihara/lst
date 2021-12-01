#!/bin/bash

# Start smbd
service smbd start
service ssh start

# Keep alive
tail -f /dev/null
#/bin/bash