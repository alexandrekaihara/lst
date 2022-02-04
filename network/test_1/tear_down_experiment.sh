#!/bin/bash

# Destroy all containers
docker-compose down
#echo -e "y\n" | docker system prune

# Remove OpenvSwitch configurations
ovs-vsctl --if-exists del-br ${INTERNAL}
ovs-vsctl --if-exists del-br ${EXTERNAL}

# Delete all namespaces created
rm -r -f /var/run/netns

# Stop controller
PID=`pgrep ryu`
if [ ! -z "$PID" ]; then kill $PID; fi



