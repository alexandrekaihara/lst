#!/bin/bash
# NOTE: If your internet access adapter is not called eth0, then 
# substitute all eth0 for the name of your adapter.


# Destroy all containers
docker-compose down

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br br-int
dhclient eth0

# Delete all namespaces created
rm -r /var/run/netns

# Stop controller
PID=`pgrep ryu`
kill $PID


