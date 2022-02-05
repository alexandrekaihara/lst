#!/bin/bash
# NOTE: If your internet access adapter is not called eth0, then 
# substitute all eth0 for the name of your adapter.


# Destroy all containers
docker-compose down
#echo -e "y\n" | docker system prune

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br br-int

# Delete all namespaces created
rm -r -f /var/run/netns

# Stop controller
PID=`pgrep ryu`
if [ ! -z "$PID" ]; then kill $PID; fi



