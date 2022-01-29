#!/bin/bash

# Destroy all containers
docker-compose down

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br br-int
dhclient eth0

# Delete all namespaces created
rm -r /var/run/netns

# Stop controller
PID=${'pgrep ryu'}
kill $PID


